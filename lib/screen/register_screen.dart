import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lockin/services/auth_service.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Text(
                'Register',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 32),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
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
              SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'E-mail',
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
              SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: 'Phone',
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
              SizedBox(height: 12),
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
              SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
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
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  final phone = phoneController.text.trim();
                  final password = passwordController.text.trim();
                  final confirmPassword = confirmPasswordController.text.trim();

                  if (password != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match!')),
                    );
                    return;
                  }
                  if (password.length < 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password must be at least 10 characters',
                        ),
                      ),
                    );
                    return;
                  }

                  final userOrError = await AuthService.signUp(email, password);

                  if (userOrError is User) {
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/user-type',
                      ); // route fix here!
                    }
                  } else if (userOrError is String && context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(userOrError)));
                  }
                },
                child: Text('Register'),
              ),

              SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  'Have account? Sign In',
                  style: TextStyle(color: Colors.purple[200]),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
