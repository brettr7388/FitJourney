import 'package:flutter/material.dart';

class NewWorkoutPlanStep2 extends StatefulWidget {
  final String gender;
  final double height;
  final double weight;
  final int age;

  NewWorkoutPlanStep2({
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
  });

  @override
  _NewWorkoutPlanStep2State createState() => _NewWorkoutPlanStep2State();
}

class _NewWorkoutPlanStep2State extends State<NewWorkoutPlanStep2> {
  String? _selectedGoal;
  late double bmi;

  @override
  void initState() {
    super.initState();
    bmi = (widget.weight * 703) / (widget.height * widget.height);
  }

  Color _bmiColor() {
    return (bmi >= 18.5 && bmi <= 24.9) ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Workout Plan', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Your Current BMI Is:',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                color: _bmiColor(),
                child: Center(
                  child: Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGoal,
                hint: Text('Enter Your Desired Goal', style: TextStyle(color: Colors.black)),
                items: <String>['Lose Weight', 'Maintain Weight', 'Weight Gain/Muscle Building']
                    .map((String goal) {
                  return DropdownMenuItem<String>(
                    value: goal,
                    child: Text(goal, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGoal = newValue;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_selectedGoal != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Workout plan submitted')),
                    );
                    Navigator.popUntil(context, ModalRoute.withName('/home'));
                  }
                },
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}