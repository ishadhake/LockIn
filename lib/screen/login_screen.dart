import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lockin/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Username',
                hintStyle: TextStyle(color: Colors.purple[200]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.purple[200]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple, width: 2),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              // ... your decoration code ...
              style: TextStyle(color: Colors.white),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showForgotPasswordDialog(context),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.purple[200]),
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                final result = await AuthService.signIn(email, password);
                if (result is User) {
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/user-type');
                  }
                } else if (result is String) {
                  // Now shows Firebase's actual message!
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(result)));
                  }
                }
              },
              child: Text('LOGIN'),
            ),
            SizedBox(height: 16), // Add spacing between buttons

            ElevatedButton.icon(
              onPressed: () async {
                final user = await AuthService.signInWithGoogle();
                if (user != null && context.mounted) {
                  Navigator.pushReplacementNamed(context, '/user-type');
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google Sign-In failed.')),
                    );
                  }
                }
              },
              icon: Icon(Icons.login, color: Colors.white),
              label: Text(
                'Sign in with Google',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Optional: style as Google color
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: Text(
                'No account? Register',
                style: TextStyle(color: Colors.purple[200]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showForgotPasswordDialog(BuildContext context) {
  String email = '';
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reset Password'),
      content: TextField(
        decoration: const InputDecoration(hintText: 'Enter your email'),
        onChanged: (value) => email = value,
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Send Reset Link'),
          onPressed: () async {
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: email.trim(),
              );
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset link sent to email'),
                  ),
                );
              }
            } catch (e) {
              print('Password reset error: $e');
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            }
          },
        ),
      ],
    ),
  );
}
