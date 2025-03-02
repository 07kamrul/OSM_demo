import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../data/models/user.dart';
import '../enum.dart';
import 'auth_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController fullnameController = TextEditingController();
  late final TextEditingController firstnameController =
      TextEditingController();
  late final TextEditingController lastnameController = TextEditingController();
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    fullnameController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) => _buildBody(context, constraints),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Register'),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildBody(BuildContext context, BoxConstraints constraints) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < AppConstants.smallScreenBreakpoint;
    final isLargeScreen = size.width >= AppConstants.largeScreenBreakpoint;
    final isLandscape = constraints.maxWidth > constraints.maxHeight;

    final iconSize =
        size.width * AppConstants.iconScale * (isSmallScreen ? 0.8 : 1.0);
    final inputHeight = size.height * AppConstants.inputHeightScale;
    final fontSize =
        size.width * AppConstants.fontScale * (isSmallScreen ? 0.9 : 1.0);
    final paddingValue = size.width * AppConstants.paddingScale;
    final spacing = size.height * AppConstants.spacingScale;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AuthScreen()),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) => Center(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                Icon(Icons.person_add,
                    color: Colors.blueAccent, size: iconSize),
                SizedBox(height: spacing),
                _buildTextField(fullnameController, 'Full Name', Icons.person,
                    fontSize, inputHeight),
                SizedBox(height: spacing),
                _buildTextField(firstnameController, 'First Name', Icons.person,
                    fontSize, inputHeight),
                SizedBox(height: spacing),
                _buildTextField(lastnameController, 'Last Name', Icons.person,
                    fontSize, inputHeight),
                SizedBox(height: spacing),
                _buildTextField(emailController, 'Email', Icons.email, fontSize,
                    inputHeight,
                    keyboardType: TextInputType.emailAddress),
                SizedBox(height: spacing),
                _buildPasswordField(fontSize, inputHeight),
                SizedBox(height: spacing),
                _buildRegisterButton(context, state, fontSize, inputHeight),
                SizedBox(height: spacing),
                _buildLoginLink(context, fontSize),
              ],
            ),
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
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label, icon, fontSize),
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }

  Widget _buildPasswordField(double fontSize, double height) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: passwordController,
        obscureText: _obscureText,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(fontSize: fontSize),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.lock, size: fontSize),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              size: fontSize,
            ),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }

  Widget _buildRegisterButton(
      BuildContext context, AuthState state, double fontSize, double height) {
    return ElevatedButton(
      onPressed: state is AuthLoading ? null : () => _handleRegister(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, height),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: state is AuthLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text('Register', style: TextStyle(fontSize: fontSize)),
    );
  }

  Widget _buildLoginLink(BuildContext context, double fontSize) {
    return TextButton(
      onPressed: () => _navigateTo(context, AuthScreen()),
      child: Text(
        "Already have an account? Login",
        style: TextStyle(color: Colors.blueAccent, fontSize: fontSize * 0.9),
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

  void _handleRegister(BuildContext context) {
    final fields = [
      fullnameController.text.trim(),
      firstnameController.text.trim(),
      lastnameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    ];
    if (fields.any((field) => field.isEmpty)) {
      _showSnackBar(context, 'Please fill all fields', Colors.red);
      return;
    }
    final user = User(
      id: 0,
      fullname: fields[0],
      firstname: fields[1],
      lastname: fields[2],
      email: fields[3],
      password: fields[4],
    );
    context.read<AuthBloc>().add(RegisterEvent(user));
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }
}
