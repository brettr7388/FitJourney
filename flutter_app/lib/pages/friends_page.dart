import 'package:flutter/material.dart';
import 'add_friend_page.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  int _selectedLeaderboard = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLeaderboard = 0;
                      });
                    },
                    child: Text('Friends'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedLeaderboard == 0 ? Colors.blue : Colors.grey[300],
                      foregroundColor: _selectedLeaderboard == 0 ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLeaderboard = 1;
                      });
                    },
                    child: Text('Global'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedLeaderboard == 1 ? Colors.blue : Colors.grey[300],
                      foregroundColor: _selectedLeaderboard == 1 ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.black),
                  onPressed: () {
                    Navigator.pushNamed(context, '/addFriend');
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _selectedLeaderboard == 0
                    ? Text('Friends Leaderboard Streaks', style: TextStyle(fontSize: 18, color: Colors.black))
                    : Text('Global Leaderboard Streaks', style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}