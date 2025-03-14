import 'package:flutter/material.dart';
import 'package:gis_osm/data/repositories/auth_repository.dart';
import 'package:gis_osm/screen/auth_screen.dart';
import '../../data/models/name_value_pair.dart';
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
  String? _selectedKoumoku5;
  String? _selectedKoumoku6;
  String? _selectedKoumoku7;
  String? _selectedKoumoku8;
  String? _selectedKoumoku9;
  String? _selectedKoumoku10;

  bool _isLoading = true;
  String? _errorMessage;

  NameValuePair _koumoku1 = new NameValuePair(name: '', values: []);
  NameValuePair _koumoku2 = new NameValuePair(name: '', values: []);
  NameValuePair _koumoku3 = new NameValuePair(name: '', values: []);
  NameValuePair _koumoku4 = new NameValuePair(name: '', values: []);
  NameValuePair _koumoku5 = new NameValuePair(name: '', values: []);
  NameValuePair _koumoku6 = new NameValuePair(name: '', values: []);
  NameValuePair _koumoku7 = new NameValuePair(name: '', values: []);
  NameValuePair _koumoku8 = new NameValuePair(name: '', values: []);
  NameValuePair _koumoku9 = new NameValuePair(name: '', values: []);
  NameValuePair _koumoku10 = new NameValuePair(name: '', values: []);

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
        _koumoku5 = response.itemList.Koumoku5;
        _koumoku6 = response.itemList.Koumoku6;
        _koumoku7 = response.itemList.Koumoku7;
        _koumoku8 = response.itemList.Koumoku8;
        _koumoku9 = response.itemList.Koumoku9;
        _koumoku10 = response.itemList.Koumoku10;
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
        _selectedKoumoku4 == null ||
        _selectedKoumoku5 == null ||
        _selectedKoumoku6 == null ||
        _selectedKoumoku7 == null ||
        _selectedKoumoku8 == null ||
        _selectedKoumoku9 == null ||
        _selectedKoumoku10 == null) {
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
      koumoku5: _selectedKoumoku5!,
      koumoku6: _selectedKoumoku6!,
      koumoku7: _selectedKoumoku7!,
      koumoku8: _selectedKoumoku8!,
      koumoku9: _selectedKoumoku9!,
      koumoku10: _selectedKoumoku10!,
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
    final inputHeight =
        size.height * 0.07; // Setting a consistent height for inputs
    final spacing = size.height * 0.02; // Adjust spacing for responsiveness

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
            : SingleChildScrollView(
                child: Column(
                children: [
                  SizedBox(height: spacing),
                  if (_koumoku1
                      .values.isNotEmpty) // Check if _koumoku1 is not empty
                    _buildKoumokuDropdown(
                        _koumoku1.name,
                        _selectedKoumoku1,
                        (value) => setState(() => _selectedKoumoku1 = value),
                        _koumoku1.values),
                  if (_koumoku2
                      .values.isNotEmpty) // Check if _koumoku2 is not empty
                    _buildKoumokuDropdown(
                        _koumoku2.name,
                        _selectedKoumoku2,
                        (value) => setState(() => _selectedKoumoku2 = value),
                        _koumoku2.values),
                  if (_koumoku3
                      .values.isNotEmpty) // Check if _koumoku3 is not empty
                    _buildKoumokuDropdown(
                        _koumoku3.name,
                        _selectedKoumoku3,
                        (value) => setState(() => _selectedKoumoku3 = value),
                        _koumoku3.values),
                  if (_koumoku4
                      .values.isNotEmpty) // Check if _koumoku4 is not empty
                    _buildKoumokuDropdown(
                        _koumoku4.name,
                        _selectedKoumoku4,
                        (value) => setState(() => _selectedKoumoku4 = value),
                        _koumoku4.values),
                  if (_koumoku5
                      .values.isNotEmpty) // Check if _koumoku5 is not empty
                    _buildKoumokuDropdown(
                        _koumoku5.name,
                        _selectedKoumoku5,
                        (value) => setState(() => _selectedKoumoku5 = value),
                        _koumoku5.values),
                  if (_koumoku6
                      .values.isNotEmpty) // Check if _koumoku6 is not empty
                    _buildKoumokuDropdown(
                        _koumoku6.name,
                        _selectedKoumoku6,
                        (value) => setState(() => _selectedKoumoku6 = value),
                        _koumoku6.values),
                  if (_koumoku7
                      .values.isNotEmpty) // Check if _koumoku7 is not empty
                    _buildKoumokuDropdown(
                        _koumoku7.name,
                        _selectedKoumoku7,
                        (value) => setState(() => _selectedKoumoku7 = value),
                        _koumoku7.values),
                  if (_koumoku8
                      .values.isNotEmpty) // Check if _koumoku8 is not empty
                    _buildKoumokuDropdown(
                        _koumoku8.name,
                        _selectedKoumoku8,
                        (value) => setState(() => _selectedKoumoku8 = value),
                        _koumoku8.values),
                  if (_koumoku9
                      .values.isNotEmpty) // Check if _koumoku9 is not empty
                    _buildKoumokuDropdown(
                        _koumoku9.name,
                        _selectedKoumoku9,
                        (value) => setState(() => _selectedKoumoku9 = value),
                        _koumoku9.values),
                  if (_koumoku10
                      .values.isNotEmpty) // Check if _koumoku10 is not empty
                    _buildKoumokuDropdown(
                        _koumoku10.name,
                        _selectedKoumoku10,
                        (value) => setState(() => _selectedKoumoku10 = value),
                        _koumoku10.values),
                  SizedBox(height: spacing),
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
              )),
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
