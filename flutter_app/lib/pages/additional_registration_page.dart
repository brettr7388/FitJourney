import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class AdditionalRegistrationPage extends StatefulWidget {
  const AdditionalRegistrationPage({Key? key}) : super(key: key);

  @override
  _AdditionalRegistrationPageState createState() => _AdditionalRegistrationPageState();
}

class _AdditionalRegistrationPageState extends State<AdditionalRegistrationPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGoal;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCongratulationsDialog();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Email Verified', style: TextStyle(color: Colors.black)),
        content: const Text(
          'Congratulations, your email has been verified.',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAdditionalInfo() async {
    final url = Uri.parse('https://fitjourneyhome.com/api/user-info'); // Ensure this endpoint is correct
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'height': int.tryParse(_heightController.text) ?? 0,
          'weight': int.tryParse(_weightController.text) ?? 0,
          'age': int.tryParse(_ageController.text) ?? 0,
          'goal': _selectedGoal ?? 'Not Specified',
        }),
      );

      if (response.statusCode == 200) {
        _confettiController.play();
        await _resetStreak() ;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Additional information submitted successfully')),
        );
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        });
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorDialog(context, errorData['error'] ?? 'Failed to submit information');
      }
    } catch (error) {
      _showErrorDialog(context, 'An error occurred: $error');
    }
  }

  Future<void> _resetStreak() async {
    final url = Uri.parse('https://fitjourneyhome.com/api/reset-streak'); // Ensure this endpoint is correct
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
      } else {
        final errorData = jsonDecode(response.body);
        _showErrorDialog(context, errorData['error'] ?? 'Failed to reset streak');
      }
    } catch (error) {
      _showErrorDialog(context, 'An error occurred: $error');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error', style: TextStyle(color: Colors.black)),
        content: Text(message, style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complete Registration',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle : true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Please enter your additional details',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Height (inches)',
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Weight (lbs)',
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Age (years)',
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedGoal,
                          decoration: const InputDecoration(
                            labelText: 'Select Your Goal',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Lose Weight', child: Text('Lose Weight')),
                            DropdownMenuItem(value: 'Maintain Weight', child: Text('Maintain Weight')),
                            DropdownMenuItem(value: 'Weight Gain/Muscle Build', child: Text('Weight Gain/Muscle Build')),
                          ],
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGoal = newValue;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _submitAdditionalInfo,
                    child: const Text('Register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.blue,
                  Colors.red,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}