import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/app_bar_action_name.dart';
import 'distance_tracker_page.dart';
import 'register_screen.dart';

class _Constants {
  static const double logoScale = 0.3;
  static const double inputHeightScale = 0.06;
  static const double fontScale = 0.04;
  static const double paddingScale = 0.05;
  static const double buttonHeightScale = 0.07;
  static const double spacingScale = 0.02;
  static const int smallScreenBreakpoint = 400;
  static const int largeScreenBreakpoint = 600;
  static const double appBarFontScale = 0.05;
}

class AuthScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _showSnackBar(context, state.message, Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DistanceTrackerPage()),
          );
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(size),
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) => _buildBody(context, constraints),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Size size) {
    final appBarFontSize = size.width * _Constants.appBarFontScale;

    return AppBar(
      title: Text('Login', style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: appBarFontSize,
      ),),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildBody(BuildContext context, BoxConstraints constraints) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < _Constants.smallScreenBreakpoint;
    final isLargeScreen = size.width >= _Constants.largeScreenBreakpoint;
    final isLandscape = constraints.maxWidth > constraints.maxHeight;

    final logoSize = size.width * _Constants.logoScale * (isSmallScreen ? 0.8 : 1.0);
    final inputHeight = size.height * _Constants.inputHeightScale;
    final fontSize = size.width * _Constants.fontScale * (isSmallScreen ? 0.9 : 1.0);
    final paddingValue = size.width * _Constants.paddingScale;
    final buttonHeight = size.height * _Constants.buttonHeightScale;
    final spacing = size.height * _Constants.spacingScale;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: paddingValue,
          vertical: isLandscape ? paddingValue * 0.5 : paddingValue,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isLargeScreen ? 400 : double.infinity),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: logoSize, color: Colors.blueAccent),
              SizedBox(height: spacing),
              _buildTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                fontSize: fontSize,
                height: inputHeight,
              ),
              SizedBox(height: spacing),
              _buildTextField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
                fontSize: fontSize,
                height: inputHeight,
              ),
              SizedBox(height: spacing),
              _buildErrorMessage(context, fontSize),
              SizedBox(height: spacing * 0.5),
              _buildLoginButton(context, fontSize, buttonHeight),
              SizedBox(height: spacing),
              _buildRegisterButton(context, fontSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double fontSize,
    required double height,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: fontSize),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(icon, size: fontSize),
          contentPadding: EdgeInsets.symmetric(vertical: height * 0.2),
        ),
        style: TextStyle(fontSize: fontSize),
        textAlignVertical: TextAlignVertical.center,
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, double fontSize) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => state is AuthFailure
          ? Text(
        state.error,
        style: TextStyle(color: Colors.red, fontSize: fontSize * 0.8),
        textAlign: TextAlign.center,
      )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildLoginButton(BuildContext context, double fontSize, double height) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => ElevatedButton(
        onPressed: state is AuthLoading
            ? null
            : () => _handleLogin(context, emailController.text.trim(), passwordController.text.trim()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: state is AuthLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('Login', style: TextStyle(fontSize: fontSize)),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context, double fontSize) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RegisterScreen()),
      ),
      child: Text(
        "Don't have an account? Register",
        style: TextStyle(color: Colors.blueAccent, fontSize: fontSize * 0.9),
      ),
    );
  }

  void _handleLogin(BuildContext context, String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Please fill all fields', Colors.red);
      return;
    }
    context.read<AuthBloc>().add(LoginEvent(email, password));
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}