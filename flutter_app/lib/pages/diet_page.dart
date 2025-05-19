import 'package:flutter/material.dart';
import 'add_meal_page.dart';

class DietPage extends StatelessWidget {
  final List<double> calorieData = [];
  final List<double> proteinData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Diet", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Calories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 10),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: calorieData.isEmpty
                      ? Text("No Data", style: TextStyle(color: Colors.black54))
                      : Text("Calories Graph"),
                ),
              ),
              SizedBox(height: 20),
              Text("Protein", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 10),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: proteinData.isEmpty
                      ? Text("No Data", style: TextStyle(color: Colors.black54))
                      : Text("Protein Graph"),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/addMeal');
                },
                child: Text("Add Meal"),
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