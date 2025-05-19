// lib/models/user.dart

class User {
  final String firstName;
  final String lastName;
  final String email;
  final String login;
  final String id;
  final String? token; // Add token as an optional field

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.login,
    required this.id,
    this.token, // Initialize token as optional
  });
}