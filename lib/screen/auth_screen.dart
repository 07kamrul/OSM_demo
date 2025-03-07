import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_osm/screen/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../data/repositories/auth_repository.dart'; // Add this import
import '../enum.dart';
import 'distance_tracker_page.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  Future<bool> _isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTime = prefs.getInt('loginTime');
    final token = prefs.getString('authToken');

    if (loginTime == null || token == null) return false;

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final sessionDuration =
        const Duration(minutes: AppConstants.sessionTimeoutHours)
            .inMilliseconds;
    return currentTime - loginTime < sessionDuration;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isSessionValid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final isLoggedIn = snapshot.data ?? false;
        return BlocProvider(
          create: (context) =>
              AuthBloc(AuthRepository()), // Pass required dependency
          child: MaterialApp(
            home: isLoggedIn ? const DistanceTrackerPage() : AuthScreen(),
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}

class AuthScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'authToken', 'some_token'); // Replace with actual token
          await prefs.setInt(
              'loginTime', DateTime.now().millisecondsSinceEpoch);
          _showSnackBar(context, state.message, Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DistanceTrackerPage()),
          );
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) => _buildBody(context, constraints),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.width * 0.04;

    return AppBar(
        title: Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent);
  }

  Widget _buildBody(BuildContext context, BoxConstraints constraints) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < AppConstants.smallScreenBreakpoint;
    final isLargeScreen = size.width >= AppConstants.largeScreenBreakpoint;
    final isLandscape = constraints.maxWidth > constraints.maxHeight;

    final logoSize =
        size.width * AppConstants.logoScale * (isSmallScreen ? 0.8 : 1.0);
    final inputHeight = size.height * AppConstants.inputHeightScale;
    final fontSize =
        size.width * AppConstants.fontScale * (isSmallScreen ? 0.9 : 1.0);
    final paddingValue = size.width * AppConstants.paddingScale;
    final buttonHeight = size.height * AppConstants.buttonHeightScale;
    final spacing = size.height * AppConstants.spacingScale;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: paddingValue,
          vertical: isLandscape ? paddingValue * 0.5 : paddingValue,
        ),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: isLargeScreen ? 400 : double.infinity),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: logoSize, color: Colors.lightBlueAccent),
              SizedBox(height: spacing),
              _buildTextField(
                  emailController, 'Email', Icons.email, fontSize, inputHeight,
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: spacing),
              _buildTextField(passwordController, 'Password', Icons.lock,
                  fontSize, inputHeight,
                  obscureText: true),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    double fontSize,
    double height, {
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: _inputDecoration(label, icon, fontSize),
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

  Widget _buildLoginButton(
      BuildContext context, double fontSize, double height) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => ElevatedButton(
        onPressed: state is AuthLoading
            ? null
            : () => _handleLogin(context, emailController.text.trim(),
                passwordController.text.trim()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, height),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        style:
            TextStyle(color: Colors.lightBlueAccent, fontSize: fontSize * 0.9),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label, IconData icon, double fontSize) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: fontSize),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon, size: fontSize),
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
