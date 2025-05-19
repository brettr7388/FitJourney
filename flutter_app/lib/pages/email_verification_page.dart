import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  Future<void> _login(BuildContext context, String username, String password) async {
    final url = Uri.parse('https://fitjourneyhome.com/api/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'login': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];

        String firstName = userData['firstName'] ?? 'No first name provided';
        String lastName = userData['lastName'] ?? 'No last name provided';
        String email = userData['email'] ?? 'No email provided';
        String userLogin = userData['login'] ?? username;
        String id = userData['id'] ?? 'No ID provided';
        String? token = data['token'];

        // Set user in provider
        Provider.of<UserProvider>(context, listen: false).setUser (
          User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            login: userLogin,
            id: id,
            token: token,
          ),
        );

        // Navigate to Additional Registration Page after successful login
        Navigator.pushReplacementNamed(context, '/additionalRegistration');
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['errors']?.join(', ') ?? 'Login failed';
        _showErrorDialog(context, errorMessage);
      }
    } catch (error) {
      _showErrorDialog(context, 'An error occurred: $error');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String username = args['username'];
    final String password = args['password'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verify Your Email',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.email_outlined,
                size: 100,
                color: Colors.black54,
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Check Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'A verification email has been sent. Please check your inbox and verify your email address.',
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  _login(context, username, password);
                },
                child: const Text('Confirm'), // Changed button text to "Confirm"
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}