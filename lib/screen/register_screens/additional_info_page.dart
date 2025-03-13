import 'package:flutter/material.dart';
import 'package:gis_osm/data/repositories/auth_repository.dart';
import 'package:gis_osm/screen/auth_screen.dart';
import '../../data/models/item_list.dart';
import '../../data/repositories/item_list_repository.dart';
import '../../data/models/user.dart';

class AdditionalInfoPage extends StatefulWidget {
  final Map<String, String> personalInfo;

  const AdditionalInfoPage({super.key, required this.personalInfo});

  @override
  State<AdditionalInfoPage> createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends State<AdditionalInfoPage> {
  final ItemListRepository _itemListRepository = ItemListRepository();
  final AuthRepository _authRepository = AuthRepository();

  String? _selectedKoumoku1;
  String? _selectedKoumoku2;
  String? _selectedKoumoku3;
  String? _selectedKoumoku4;

  bool _isLoading = true;
  String? _errorMessage;

  List<String> _koumoku1 = [];
  List<String> _koumoku2 = [];
  List<String> _koumoku3 = [];
  List<String> _koumoku4 = [];

  @override
  void initState() {
    super.initState();
    _fetchItemList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
    debugPrint(message);
  }

  Future<void> _fetchItemList() async {
    try {
      final response = await _itemListRepository.getItemList();

      setState(() {
        _koumoku1 = response.itemList.Koumoku1;
        _koumoku2 = response.itemList.Koumoku2;
        _koumoku3 = response.itemList.Koumoku3;
        _koumoku4 = response.itemList.Koumoku4;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Show SnackBar
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _handleRegister(BuildContext context) async {
    // Check if any field is empty
    if (widget.personalInfo.values.any((field) => field.isEmpty)) {
      _showSnackBar(context, 'Please fill all fields', Colors.red);
      return;
    }

    // Ensure selected values are not null
    if (_selectedKoumoku1 == null ||
        _selectedKoumoku2 == null ||
        _selectedKoumoku3 == null ||
        _selectedKoumoku4 == null) {
      _showSnackBar(context, 'Please select all the options', Colors.red);
      return;
    }

    // Create a User object
    final user = User(
      id: 0,
      fullname: widget.personalInfo['fullname']!,
      firstname: widget.personalInfo['firstname']!,
      lastname: widget.personalInfo['lastname']!,
      email: widget.personalInfo['email']!,
      password: widget.personalInfo['password']!,
      profile_pic: '',
      gender: widget.personalInfo['gender']!,
      dob: widget.personalInfo['dob']!,
      status: 'Active',
      koumoku1: _selectedKoumoku1!,
      koumoku2: _selectedKoumoku2!,
      koumoku3: _selectedKoumoku3!,
      koumoku4: _selectedKoumoku4!,
      koumoku5: '', // Add koumoku logic if required
      koumoku6: '', // Add koumoku logic if required
      koumoku7: '', // Add koumoku logic if required
      koumoku8: '', // Add koumoku logic if required
      koumoku9: '', // Add koumoku logic if required
      koumoku10: '', // Add koumoku logic if required
    );

    try {
      // Register the user
      final response = await _authRepository.register(user);

      // Check if the response is successful
      if (response['status'] == 'OK') {
        // Navigate to another screen (e.g., login or home)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AuthScreen()),
        );
      } else {
        // Show an error if registration failed
        _showSnackBar(
            context, response['message'] ?? 'Registration failed', Colors.red);
      }
    } catch (e) {
      // Handle errors in registration
      _showSnackBar(context, 'An error occurred: ${e.toString()}', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.width * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text("Additional Information"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : Column(
                children: [
                  _buildKoumokuDropdown(
                      'Koumoku 1',
                      _selectedKoumoku1,
                      (value) => setState(() => _selectedKoumoku1 = value),
                      _koumoku1),
                  _buildKoumokuDropdown(
                      'Koumoku 2',
                      _selectedKoumoku2,
                      (value) => setState(() => _selectedKoumoku2 = value),
                      _koumoku2),
                  _buildKoumokuDropdown(
                      'Koumoku 3',
                      _selectedKoumoku3,
                      (value) => setState(() => _selectedKoumoku3 = value),
                      _koumoku3),
                  _buildKoumokuDropdown(
                      'Koumoku 4',
                      _selectedKoumoku4,
                      (value) => setState(() => _selectedKoumoku4 = value),
                      _koumoku4),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _handleRegister(context),
                    child: Text("Register"),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildKoumokuDropdown(String label, String? selectedValue,
      Function(String?) onChanged, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        isExpanded: true, // Ensure the dropdown takes up full width
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8), // Adjusted padding
          constraints: const BoxConstraints(
              minWidth: 100), // Minimum width to avoid collapse
        ),
        items: items.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option,
                style:
                    TextStyle(fontSize: 16)), // Adjust the font size of items
          );
        }).toList(),
        onChanged: onChanged,
        isDense: true, // Reduces vertical height
        dropdownColor: Colors.white, // Consistent dropdown background
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}
