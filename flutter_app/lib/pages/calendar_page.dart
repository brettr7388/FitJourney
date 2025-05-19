import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added for persistent storage
import '../providers/user_provider.dart';
import '../providers/user_stats_provider.dart'; // Import for user stats

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // For demonstration, the year is fixed at 2025.
  DateTime _currentMonth = DateTime(2025, DateTime.now().month, 1);
  int _streak = 0;
  // Holds status for each day via a composite key.
  Map<String, String> _dayStatus = {};
  // Holds user notes for each day.
  Map<String, String> _dayNotes = {};
  int? _selectedDay;
  String? _selectedStatus; // For current day's status.
  // Controller for notes text field.
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    // If the calendar's current month matches today's month, pre-select today's day.
    if (_currentMonth.month == DateTime.now().month) {
      _selectedDay = DateTime.now().day;
      _notesController.text = _dayNotes[_dayKey(_selectedDay!)] ?? '';
    }
    // Load saved calendar progress and fetch the current streak from the backend.
    _loadCalendarData();
    _fetchStreak();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Generate a unique key for each day.
  String _dayKey(int day) {
    return "${_currentMonth.year}-${_currentMonth.month}-$day";
  }

  // Return a workout plan based on the user's goal.
  // This method now uses the goal from UserStatsProvider.
  Map<String, String> _getWorkoutPlan() {
    // Obtain the userStats from its provider; it holds the goal field.
    final userStats = Provider.of<UserStatsProvider>(context, listen: true).userStats;
    String userGoal = userStats?.goal ?? "Maintain Weight";

    if (userGoal == "Lose Weight") {
      return {
        "Squats": "3x8",
        "Bench Press": "3x8",
        "Deadlift": "3x8",
        "Running": "3 miles",
      };
    } else if (userGoal == "Weight Gain/Muscle Build") {
      return {
        "Squats": "4x8",
        "Bench Press": "4x8",
        "Deadlift": "4x8",
        "Running": "1 mile",
      };
    } else {
      // Default: Maintain Weight
      return {
        "Squats": "3x12",
        "Bench Press": "3x12",
        "Deadlift": "3x12",
        "Running": "2 miles",
      };
    }
  }

  // Return the month name.
  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  // Return the number of days in the current month.
  int _daysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  // When a day is tapped, update the selection and update notes controller;
  // then immediately switch to the "To Do" tab.
  void _onDayTapped(BuildContext context, int day) {
    setState(() {
      _selectedDay = day;
      _selectedStatus = null;
      _notesController.text = _dayNotes[_dayKey(day)] ?? '';
    });
    // Switch to the "To Do" tab (Tab index 1).
    DefaultTabController.of(context)?.animateTo(1);
  }

  // Confirm status and update streak on the backend.
  void _confirmStatus() async {
    print("Confirm Status Button Pressed"); // Debugging line
    if (_selectedDay != null && _selectedStatus != null) {
      String key = _dayKey(_selectedDay!);

      // Update the day status first
      setState(() {
        _dayStatus[key] = _selectedStatus!;
      });

      // Debug print the selected status.
      print("Selected Status: '$_selectedStatus'");

      // Update streak based on status.
      if (_selectedStatus!.trim() == "Worked Out") {
        _streak++;
        print("Incrementing streak...");
        await _incrementStreak(); // Call the increment streak function
      } else if (_selectedStatus!.trim() == "Missed") {
        _streak = 0;
        print("Resetting streak...");
        await _resetStreak(); // Call the reset streak function
      } else {
        print("Status did not match: '$_selectedStatus'");
      }

      // Now reset selected status.
      setState(() {
        _selectedStatus = null;
      });
      // Save calendar changes locally.
      await _saveCalendarData();
    } else {
      print("Selected Day: $_selectedDay, Selected Status: $_selectedStatus");
    }
  }

  // Function to increment the streak using the backend.
  Future<void> _incrementStreak() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final url = Uri.parse('https://fitjourneyhome.com/api/increment-streak');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user?.token}',
        },
        body: json.encode({'userId': user?.id}),
      );

      if (response.statusCode == 200) {
        print('Streak incremented successfully.');
      } else {
        print('Failed to increment streak: ${response.body}');
      }
    } catch (error) {
      print('Error incrementing streak: $error');
    }
  }

  // Function to reset the streak using the backend.
  Future<void> _resetStreak() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final url = Uri.parse('https://fitjourneyhome.com/api/reset-streak');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user?.token}',
        },
        body: json.encode({'userId': user?.id}),
      );

      if (response.statusCode == 200) {
        print('Streak reset successfully.');
      } else {
        print('Failed to reset streak: ${response.body}');
      }
    } catch (error) {
      print('Error resetting streak: $error');
    }
  }

  // Function to fetch the current streak from the backend.
  Future<void> _fetchStreak() async {
  final user = Provider.of<UserProvider>(context, listen: false).user;
  if (user == null) return;

  final url = Uri.parse('https://fitjourneyhome.com/api/streak?userId=${user.id}');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.token}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (mounted) {
        setState(() {
          _streak = data['streaks'];
        });
      }
    } else {
      print('Failed to fetch streak: ${response.body}');
    }
  } catch (error) {
    print('Error fetching streak: $error');
  }
}


  // Load saved calendar day statuses and notes from local storage.
  Future<void> _loadCalendarData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    String userId = user?.id.toString() ?? "default";
    String? statusJson = prefs.getString('dayStatus_$userId');
    if (statusJson != null) {
      setState(() {
        _dayStatus = Map<String, String>.from(json.decode(statusJson));
      });
    }
    String? notesJson = prefs.getString('dayNotes_$userId');
    if (notesJson != null) {
      setState(() {
        _dayNotes = Map<String, String>.from(json.decode(notesJson));
      });
    }
  }

  Future<void> _saveCalendarData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    String userId = user?.id.toString() ?? "default";
    await prefs.setString('dayStatus_$userId', json.encode(_dayStatus));
    await prefs.setString('dayNotes_$userId', json.encode(_dayNotes));
  }

  // Build the calendar grid.
  Widget _buildCalendarGrid() {
    int daysInThisMonth = _daysInMonth(_currentMonth);
    int startingWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    int offset = startingWeekday % 7;
    int totalCells = offset + daysInThisMonth;

    return Builder(
      builder: (BuildContext context) {
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            if (index < offset) {
              return Container();
            }
            int day = index - offset + 1;
            bool isSelected = (_selectedDay != null && day == _selectedDay);
            Color cellColor = isSelected ? Colors.yellow : Colors.grey[200]!;
            String key = _dayKey(day);

            return GestureDetector(
              onTap: () => _onDayTapped(context, day),
              child: Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(day.toString(), style: TextStyle(color: Colors.black)),
                    ),
                    if (_dayStatus.containsKey(key))
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _dayStatus[key] == "Worked Out"
                                ? Colors.green
                                : _dayStatus[key] == "Rest Day"
                                    ? Colors.grey
                                    : Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Build the Calendar tab view.
  Widget _buildCalendarTab() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            // Month navigation row.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      if (_currentMonth.month > 1) {
                        _currentMonth = DateTime(2025, _currentMonth.month - 1, 1);
                        if (_currentMonth.month == DateTime.now().month) {
                          _selectedDay = DateTime.now().day;
                        } else {
                          _selectedDay = null;
                        }
                      }
                    });
                  },
                ),
                Text(
                  '${_monthName(_currentMonth.month)} 2025',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      if (_currentMonth.month < 12) {
                        _currentMonth = DateTime(2025, _currentMonth.month + 1, 1);
                        if (_currentMonth.month == DateTime.now().month) {
                          _selectedDay = DateTime.now().day;
                        } else {
                          _selectedDay = null;
                        }
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            // Days of week header.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(day,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 10),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  // Build the To Do tab view.
  Widget _buildToDoTab() {
    if (_selectedDay == null) {
      return Center(
        child: Text(
          "Select a day on the Calendar tab to view your To Do.",
          style: TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      );
    }
    Map<String, String> plan = _getWorkoutPlan();
    String displayDate = "${_monthName(_currentMonth.month)} $_selectedDay, ${_currentMonth.year}";
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("To Do for $displayDate:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 8),
            for (var exercise in plan.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text("${exercise.key}: ${exercise.value}",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
              ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Day Status",
                border: OutlineInputBorder(),
              ),
              value: _selectedStatus,
              items: const [
                DropdownMenuItem(
                  value: "Worked Out",
                  child: Text("Worked Out 💪"),
                ),
                DropdownMenuItem(
                  value: "Rest Day",
                  child: Text("Rest Day 😌"),
                ),
                DropdownMenuItem(
                  value: "Missed",
                  child: Text("Missed ❌"),
                ),
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
              },
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: _confirmStatus,
                child: Text("Confirm Status"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Build the Notes tab view.
  Widget _buildNotesTab() {
    if (_selectedDay == null) {
      return Center(
        child: Text(
          "Select a day on the Calendar tab to add/view notes.",
          style: TextStyle(fontSize: 16, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      );
    }
    String displayDate = "${_monthName(_currentMonth.month)} $_selectedDay, ${_currentMonth.year}";
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Notes for $displayDate:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 6,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
              _dayNotes[_dayKey(_selectedDay!)] = _notesController.text;
              _saveCalendarData();
            },
            onChanged: (value) {
              _dayNotes[_dayKey(_selectedDay!)] = value;
              _saveCalendarData();
            },
            decoration: InputDecoration(
              hintText: "Enter your notes here...",
              border: OutlineInputBorder(),
            ),
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(
            "Tap 'Done' on your keyboard to close it.",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Fit Journey Home Page", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "Calendar"),
              Tab(text: "To Do"),
              Tab(text: "Notes"),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome, ${user?.login ?? 'User'}!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildCalendarTab(),
                    _buildToDoTab(),
                    _buildNotesTab(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 8),
                    Text('$_streak',
                        style: TextStyle(fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
