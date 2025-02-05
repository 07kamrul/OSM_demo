import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'distance_tracker_page.dart';
import 'register_screen.dart'; // Import the RegisterScreen

class AuthScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DistanceTrackerPage()),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Login')),
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(Icons.lock, size: 80, color: Colors.blueAccent),
                SizedBox(height: 20),
                // Email Input
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 16),
                // Password Input
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 24),
                // Login Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: () {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();
                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        context.read<AuthBloc>().add(LoginEvent(email, password));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state is AuthLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Login", style: TextStyle(fontSize: 16)),
                    );
                  },
                ),
                SizedBox(height: 12),
                // Register Button
                TextButton(
                  onPressed: () {
                    // Navigate to the RegisterScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}