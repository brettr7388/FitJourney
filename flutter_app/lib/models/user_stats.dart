// lib/models/user_stats.dart

class UserStats {
  final double weight;
  final double height;
  final int age;
  final String goal;

  UserStats({
    required this.weight,
    required this.height,
    required this.age,
    required this.goal,
  });

  // Factory method to create a UserStats instance from JSON
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      weight: json['weight'].toDouble(),
      height: json['height'].toDouble(),
      age: json['age'],
      goal: json['goal'],
    );
  }

  // Method to convert UserStats instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'age': age,
      'goal': goal,
    };
  }
}