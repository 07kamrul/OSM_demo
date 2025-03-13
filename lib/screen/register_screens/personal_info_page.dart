import 'package:flutter/material.dart';
import 'additional_info_page.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late final TextEditingController fullnameController = TextEditingController();
  late final TextEditingController firstnameController =
      TextEditingController();
  late final TextEditingController lastnameController = TextEditingController();
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  late final TextEditingController dobController = TextEditingController();

  bool _obscureText = true;

  @override
  void dispose() {
    fullnameController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    dobController.dispose();
    super.dispose();
  }

  void _validateAndNavigate() {
    // Check if any required field is empty
    if (fullnameController.text.isEmpty ||
        firstnameController.text.isEmpty ||
        lastnameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        dobController.text.isEmpty) {
      // Show an error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // If all fields are filled, create a map or object to pass data to the next page
    final personalInfo = {
      'fullname': fullnameController.text,
      'firstname': firstnameController.text,
      'lastname': lastnameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'dob': dobController.text,
    };

    // Navigate to the next page and pass data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdditionalInfoPage(personalInfo: personalInfo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.width * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Information"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                    fullnameController, 'Full Name', Icons.person, fontSize),
                _buildTextField(
                    firstnameController, 'First Name', Icons.person, fontSize),
                _buildTextField(
                    lastnameController, 'Last Name', Icons.person, fontSize),
                _buildTextField(emailController, 'Email', Icons.email, fontSize,
                    keyboardType: TextInputType.emailAddress),
                _buildPasswordField(fontSize),
                _buildDOBField(fontSize),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _validateAndNavigate,
                  child: Text("Next"),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    double fontSize, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: fontSize),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(icon, size: fontSize),
        ),
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }

  Widget _buildPasswordField(double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  Widget _buildDOBField(double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: dobController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          labelStyle: TextStyle(fontSize: fontSize),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.calendar_today, size: fontSize),
          suffixIcon: IconButton(
            icon: Icon(Icons.date_range, size: fontSize),
            onPressed: _selectDate,
          ),
        ),
        style: TextStyle(fontSize: fontSize),
        onTap: _selectDate,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }
}
