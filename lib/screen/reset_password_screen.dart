import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String oobCode; // <--- add this field

  const ResetPasswordScreen({
    super.key,
    required this.oobCode,
  }); // <--- update constructor

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showSuccess = false;

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.confirmPasswordReset(
          code: widget.oobCode,
          newPassword: _newPasswordController.text.trim(),
        );
        setState(() => _showSuccess = true);
      } catch (e) {
        // Handle error gracefully, e.g., show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reset failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 12),
                  // Logo (replace with your Image.asset if needed)
                  Icon(Icons.lock, size: 50, color: Colors.blue),
                  SizedBox(height: 24),
                  Text(
                    'Change Your Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Enter a new password below to change your password.',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New password*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 10) {
                        return 'Password must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Re-enter new password*',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'At least 10 characters in length',
                          style: TextStyle(color: Colors.green[800]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text(
                      'Reset password',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  if (_showSuccess)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Password reset successful!',
                        style: TextStyle(color: Colors.green, fontSize: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
