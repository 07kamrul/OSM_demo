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
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    double logoSize = screenWidth * 0.3; // Logo size relative to screen width
    double inputHeight = screenHeight * 0.06; // Input field height relative to screen height
    double fontSize = screenWidth * 0.04; // Font size relative to screen width
    double paddingValue = screenWidth * 0.05; // Padding relative to screen width
    double buttonHeight = screenHeight * 0.07; // Button height relative to screen height

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
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login'),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: paddingValue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(Icons.lock, size: logoSize, color: Colors.blueAccent),
                SizedBox(height: screenHeight * 0.02),

                // Email Input
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(fontSize: fontSize),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.email, size: fontSize),
                  ),
                  style: TextStyle(fontSize: fontSize),
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: 1,
                ),
                SizedBox(height: screenHeight * 0.02),

                // Password Input
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(fontSize: fontSize),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock, size: fontSize),
                  ),
                  style: TextStyle(fontSize: fontSize),
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: 1,
                ),
                SizedBox(height: screenHeight * 0.02),

                // Error Message
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthFailure) {
                      return Text(
                        state.error, // Display the error message
                        style: TextStyle(color: Colors.red, fontSize: fontSize * 0.8),
                        textAlign: TextAlign.center,
                      );
                    }
                    return SizedBox.shrink(); // No error message to display
                  },
                ),
                SizedBox(height: screenHeight * 0.01),

                // Login Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: () {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();
                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please fill all fields"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        context.read<AuthBloc>().add(LoginEvent(email, password));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, buttonHeight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state is AuthLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Login", style: TextStyle(fontSize: fontSize)),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.02),

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
                    style: TextStyle(color: Colors.blueAccent, fontSize: fontSize * 0.9),
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