import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../data/models/user.dart';
import 'auth_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final iconSize = screenWidth * 0.2; // Icon size as 20% of screen width
    final inputFieldHeight =
        screenHeight * 0.07; // Input field height as 7% of screen height
    final fontSize = screenWidth * 0.04; // Font size as 4% of screen width
    final paddingValue = screenWidth * 0.05; // Padding as 5% of screen width

    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: paddingValue),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Person Add Icon
                Icon(
                  Icons.person_add,
                  color: Colors.blueAccent,
                  size: iconSize,
                ),
                SizedBox(height: screenHeight * 0.02),

                // Full Name Input
                TextField(
                  controller: fullnameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(fontSize: fontSize),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person, size: fontSize),
                  ),
                  style: TextStyle(fontSize: fontSize),
                ),
                SizedBox(height: paddingValue),

                // First Name Input
                TextField(
                  controller: firstnameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(fontSize: fontSize),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person, size: fontSize),
                  ),
                  style: TextStyle(fontSize: fontSize),
                ),
                SizedBox(height: paddingValue),

                // Last Name Input
                TextField(
                  controller: lastnameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(fontSize: fontSize),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person, size: fontSize),
                  ),
                  style: TextStyle(fontSize: fontSize),
                ),
                SizedBox(height: paddingValue),

                // Email Input
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontSize: fontSize),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email, size: fontSize),
                  ),
                  style: TextStyle(fontSize: fontSize),
                ),
                SizedBox(height: paddingValue),

                // Password Input
                TextField(
                  controller: passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: fontSize),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock, size: fontSize),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        size: fontSize,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(fontSize: fontSize),
                ),
                SizedBox(height: paddingValue),

                // Register Button with BlocConsumer
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Future.delayed(Duration(seconds: 2), () {
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => AuthScreen()),
                          );
                        }
                      });
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: () {
                        String fullname = fullnameController.text.trim();
                        String firstname = firstnameController.text.trim();
                        String lastname = lastnameController.text.trim();
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();
                        if (fullname.isEmpty || firstname.isEmpty || lastname.isEmpty || email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please fill all fields"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        final user = User(
                          id: 0,
                          fullname: fullname,
                          firstname: firstname,
                          lastname: lastname,
                          email: email,
                          password: password,
                        );
                        context.read<AuthBloc>().add(RegisterEvent(user));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, inputFieldHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is AuthLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Register",
                              style: TextStyle(fontSize: fontSize),
                            ),
                    );
                  },
                ),
                SizedBox(height: paddingValue),

                // Already have an account? Login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => AuthScreen()),
                    );
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: fontSize,
                    ),
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
