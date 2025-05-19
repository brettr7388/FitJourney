import 'package:flutter/material.dart';
import 'package:flutter_app/pages/profile_page.dart';
import 'package:flutter_app/pages/reset_password_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../providers/user_stats_provider.dart';

// ----------------------
// ShakyIcon Widget - an easter egg for the gym app.
// When tapped, it shakes the dumbbell and shows a gym message.
class ShakyIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;

  const ShakyIcon({
    Key? key,
    required this.icon,
    this.size = 64,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  _ShakyIconState createState() => _ShakyIconState();
}

class _ShakyIconState extends State<ShakyIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    // Using Tween<double> ensures that values are treated as doubles.
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -8.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -8.0, end: 8.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 8.0, end: -8.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -8.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startShake() {
    _controller.forward(from: 0.0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Never Give Up! 💪'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startShake,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: Icon(widget.icon, size: widget.size, color: widget.color),
      ),
    );
  }
}

// ----------------------
// LoginPage Widget
class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _login(BuildContext context) async {
    final String login = _usernameController.text;
    final String password = _passwordController.text;
    final url = Uri.parse('https://fitjourneyhome.com/api/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'login': login,
          'password': password,
        }),
      );

      // Debug logging.
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];

        String firstName = userData['firstName'] ?? 'No first name provided';
        String lastName = userData['lastName'] ?? 'No last name provided';
        String email = userData['email'] ?? 'No email provided';
        String userLogin = userData['login'] ?? login;
        String id = userData['id'] ?? 'No ID provided';
        String? token = data['token'];

        Provider.of<UserProvider>(context, listen: false).setUser (
          User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            login: userLogin,
            id: id,
            token: token, // Include the token here
          ),
        );
        // Fetch user stats after successful login
        await Provider.of<UserStatsProvider>(context, listen: false).fetchUserStats(id);

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage =
            errorData['errors']?.join(', ') ?? 'Login failed';
        _showErrorDialog(context, _errorMessage!);
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      _showErrorDialog(context, _errorMessage!);
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
    final userStats = Provider.of<UserStatsProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Allows for scrolling when the keyboard appears.
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                // Our interactive gym icon.
                ShakyIcon(
                  icon: Icons.fitness_center,
                  size: 64,
                  color: Colors.black,
                ),
                SizedBox(height: 20),
                Text(
                  'Fit Journey',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 40),
                // Grouping of input fields and login button.
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
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _login(context),
                        child: Text('Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text('or', style: TextStyle(color: Colors.black)),
                SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Register', style: TextStyle(color: Colors.black)),
                ),
                // Inside the LoginPage build method, add this below the Register button
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Navigate to the Reset Password page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPasswordPage(), // Pass the email if needed
                      ),
                    );
                  },
                  child: Text('Forgot Password?', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(height: 20),
                // Gym-inspired motivational text.
                Text(
                  '💪 Stay Strong! 🏋️',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
