import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/user_stats_provider.dart';
import 'reset_password_page.dart'; // Import the ResetPasswordPage

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  // Default profile values.
  int _weight = 180;
  int _height = 70;
  int _age = 25;
  String _goal = "Maintain Weight";
  int? _streak; // Streak is now nullable, defaults to null

  Future<void> _logout(BuildContext context) async {
    final url = Uri.parse('https://fitjourneyhome.com/api/logout');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200 || response.body.contains("<html")) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        _showErrorDialog(context, 'Logout failed');
      }
    } catch (error) {
      _showErrorDialog(context, 'An error occurred: $error');
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Account', style: TextStyle(color: Colors.black)),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.user?.token;
    final url = Uri.parse('https://fitjourneyhome.com/api/delete');

    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      print("DELETE request status: ${response.statusCode}");
      print("Response body: ${response.body}");
      try {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account deleted successfully.')),
          );
          userProvider.clearUser ();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else {
          _showErrorDialog(
              context, responseData['error'] ?? 'Failed to delete account');
        }
      } catch (e) {
        _showErrorDialog(context, 'Failed to parse response: ${response.body}');
      }
    } catch (error) {
      _showErrorDialog(context, 'An error occurred: $error');
    }
  }

  Future<void> _updateInformation(BuildContext context) async {
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
    final url = Uri.parse('https://fitjourneyhome.com/api/update-user-stats');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'height': _height,
          'weight': _weight,
          'age': _age,
          'goal': _goal,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Information updated successfully.')),
        );

        // Update the UserStatsProvider with new values
        Provider.of<UserStatsProvider>(context, listen: false)
            .updateUserStats(_weight.toDouble(), _height.toDouble(), _age, _goal);
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorDialog(
          context,
          errorData['error'] ?? 'Failed to update information',
        );
      }
    } catch (error) {
      _showErrorDialog(context, 'An error occurred: $error');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error', style: TextStyle(color: Colors.black)),
        content: Text(message, style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _editNumericField({
    required BuildContext context,
    required String title,
    required int currentValue,
    required Function(int) onSave,
    required String unit,
  }) async {
    final _controller = TextEditingController(text: currentValue.toString());
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $title', style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(suffixText: unit),
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              int? value = int.tryParse(_controller.text);
              if (value != null) {
                onSave(value);
                Navigator.of(ctx).pop();
              }
            },
            child: Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _editGoal(BuildContext context) async {
    String tempGoal = _goal;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Goal', style: TextStyle(color: Colors.black)),
        content: DropdownButtonFormField<String>(
          value: tempGoal,
          decoration: InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: "Lose Weight", child: Text("Lose Weight")),
            DropdownMenuItem(value: "Maintain Weight", child: Text("Maintain Weight")),
            DropdownMenuItem(
                value: "Weight Gain/Muscle Build",
                child: Text("Weight Gain/Muscle Build")),
          ],
          onChanged: (newValue) {
            if (newValue != null) tempGoal = newValue;
          },
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _goal = tempGoal;
              });
              Navigator.of(ctx).pop();
            },
            child: Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onEdit,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.black),
            SizedBox(width: 8),
          ],
          Text(
            "$label:",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(color: Colors.black),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final userStats = Provider.of<UserStatsProvider>(context, listen: false).userStats;
    _weight = userStats?.weight?.toInt() ?? 180;
    _height = userStats?.height?.toInt() ?? 70;
    _age = userStats?.age ?? 25;
    _goal = userStats?.goal ?? "Maintain Weight";
    _fetchStreak();
  }

  Future<void> _fetchStreak() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null || user.id == null) return;

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
        final data = jsonDecode(response.body);
        int fetchedStreak = data['streaks'];
        if (fetchedStreak == 0 && (_streak ?? 0) > 0) {
          fetchedStreak = _streak!;
        }
        if (mounted) {
          setState(() {
            _streak = fetchedStreak;
          });
        }
      } else {
        print('Failed to fetch streak: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching streak: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.black),
                      SizedBox(width: 8),
                      Text("Username:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      Spacer(),
                      Text(user?.login ?? '', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildEditableField(
                    context: context,
                    label: "Age",
                    value: "$_age years",
                    onEdit: () {
                      _editNumericField(
                        context: context,
                        title: "Age",
                        currentValue: _age,
                        unit: "years",
                        onSave: (value) {
                          setState(() {
                            _age = value;
                          });
                        },
                      );
                    },
                    icon: Icons.cake,
                  ),
                  _buildEditableField(
                    context: context,
                    label: "Height",
                    value: "$_height inches",
                    onEdit: () {
                      _editNumericField(
                        context: context,
                        title: "Height",
                        currentValue: _height,
                        unit: "inches",
                        onSave: (value) {
                          setState(() {
                            _height = value;
                          });
                        },
                      );
                    },
                    icon: Icons.height,
                  ),
                  _buildEditableField(
                    context: context,
                    label: "Weight",
                    value: "$_weight lbs",
                    onEdit: () {
                      _editNumericField(
                        context: context,
                        title: "Weight",
                        currentValue: _weight,
                        unit: "lbs",
                        onSave: (value) {
                          setState(() {
                            _weight = value;
                          });
                        },
                      );
                    },
                    icon: Icons.monitor_weight,
                  ),
                  _buildEditableField(
                    context: context,
                    label: "Goal",
                    value: _goal,
                    onEdit: () {
                      _editGoal(context);
                    },
                    icon: Icons.flag,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 32)),
                        SizedBox(width: 8),
                        Text("Streak:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        Spacer(),
                        Text(
                          _streak == null ? "Loading..." : "$_streak days",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    SizedBox(width: 16),
    Expanded(
      child: ElevatedButton(
        onPressed: () => _updateInformation(context),
        child: Text("Update Info"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    ),
    SizedBox(width: 16),
    Expanded(
      child: ElevatedButton(
        onPressed: () => _logout(context),
        child: Text("Log Out"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    ),
    SizedBox(width: 16),
    Expanded(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResetPasswordPage()),
          );
        },
        child: Center(
          child: Text(
            "Change Password",
            textAlign: TextAlign.center,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    ),
  ],
),

            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _deleteAccount(context),
                child: Text("Delete Account"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}