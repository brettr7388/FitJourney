import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isNewUser  = true;
    return Center(
      child: isNewUser
          ? ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/newWorkoutStep1');
        },
        child: Text('Create a New Workout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Today\'s Workout Plan', style: TextStyle(fontSize: 20, color: Colors.black)),
          SizedBox(height: 10),
          Text('Todo List Placeholder', style: TextStyle(fontSize: 16, color: Colors.black)),
          SizedBox(height: 10),
          Text('Calories: [Placeholder]', style: TextStyle(fontSize: 16, color: Colors.black)),
          SizedBox(height: 10),
          Text('Calendar View Placeholder', style: TextStyle(fontSize: 16, color: Colors.black)),
        ],
      ),
    );
  }
}