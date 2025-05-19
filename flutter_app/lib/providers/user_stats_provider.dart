// lib/providers/user_stats_provider.dart

import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// lib/providers/user_stats_provider.dart

class UserStatsProvider with ChangeNotifier {
  UserStats? _userStats;

  UserStats? get userStats => _userStats;

  Future<void> fetchUserStats(String userId) async {
    final url = Uri.parse('https://fitjourneyhome.com/api/get-profile?userId=$userId');

    try {
      final response = await http.get(url);
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userStats = UserStats.fromJson(data);
        notifyListeners();
      } else {
        throw Exception('Failed to load user stats');
      }
    } catch (error) {
      throw error; // Handle the error as needed
    }
  }

  // New method to update user stats
  void updateUserStats(double weight, double height, int age, String goal) {
    _userStats = UserStats(
      weight: weight,
      height: height,
      age: age,
      goal: goal,
    );
    notifyListeners();
  }
}