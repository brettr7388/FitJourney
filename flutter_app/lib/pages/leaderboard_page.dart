import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<dynamic> leaderboard = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    final url = Uri.parse('https://fitjourneyhome.com/api/leaderboard');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> limitedData = data.length > 10 ? data.sublist(0, 10) : data;
        if (!mounted) return;
        setState(() {
          leaderboard = limitedData;
          isLoading = false;
          errorMessage = '';
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error fetching leaderboard: $e';
        isLoading = false;
      });
    }
  }

  Widget buildPodium(List<dynamic> topThree) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second Place
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                topThree[1]['streaks'].toString(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 8),
              CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 30,
                child: Text(
                  topThree[1]['login'][0].toUpperCase(),
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
              SizedBox(height: 8),
              Text(topThree[1]['login'] ?? 'Unknown', style: TextStyle(color: Colors.black)),
            ],
          ),
          // First Place
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                topThree[0]['streaks'].toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 8),
              CircleAvatar(
                backgroundColor: Colors.amber,
                radius: 35,
                child: Text(
                  topThree[0]['login'][0].toUpperCase(),
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
              SizedBox(height: 8),
              Text(topThree[0]['login'] ?? 'Unknown', style: TextStyle(color: Colors.black)),
            ],
          ),
          // Third Place
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                topThree[2]['streaks'].toString(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 8),
              CircleAvatar(
                backgroundColor: Colors.brown,
                radius: 30,
                child: Text(
                  topThree[2]['login'][0].toUpperCase(),
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
              SizedBox(height: 8),
              Text(topThree[2]['login'] ?? 'Unknown', style: TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRemainingList(List<dynamic> remaining) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: remaining.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final rank = index + 4;
        final item = remaining[index];
        return ListTile(
          leading: Text(
            rank.toString(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          title: Text(
            item['login'] ?? 'Unknown',
            style: TextStyle(color: Colors.black),
          ),
          trailing: Text(
            item['streaks'].toString(),
            style: TextStyle(color: Colors.black),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.black)))
                  : RefreshIndicator(
                      onRefresh: fetchLeaderboard,
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.emoji_events, size: 32, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text(
                                    "Global Leaderboard",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            // Podium
                            if (leaderboard.length >= 3)
                              buildPodium(leaderboard.sublist(0, 3)),
                            // Remaining list
                            if (leaderboard.length > 3)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: buildRemainingList(leaderboard.sublist(3)),
                              ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
