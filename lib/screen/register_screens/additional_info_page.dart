import 'package:flutter/material.dart';

class AdditionalInfoPage extends StatefulWidget {
  final Map<String, String> personalInfo;

  const AdditionalInfoPage({super.key, required this.personalInfo});

  @override
  State<AdditionalInfoPage> createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends State<AdditionalInfoPage> {
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

  final List<String> _options = [
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4'
  ];

  @override
  void dispose() {
    super.dispose();
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
        child: Column(
          children: [
            _buildKoumokuDropdown('Koumoku 1', _selectedKoumoku1,
                (value) => setState(() => _selectedKoumoku1 = value)),
            _buildKoumokuDropdown('Koumoku 2', _selectedKoumoku2,
                (value) => setState(() => _selectedKoumoku2 = value)),
            _buildKoumokuDropdown('Koumoku 3', _selectedKoumoku3,
                (value) => setState(() => _selectedKoumoku3 = value)),
            _buildKoumokuDropdown('Koumoku 4', _selectedKoumoku4,
                (value) => setState(() => _selectedKoumoku4 = value)),
            _buildKoumokuDropdown('Koumoku 5', _selectedKoumoku5,
                (value) => setState(() => _selectedKoumoku5 = value)),
            _buildKoumokuDropdown('Koumoku 6', _selectedKoumoku6,
                (value) => setState(() => _selectedKoumoku6 = value)),
            _buildKoumokuDropdown('Koumoku 7', _selectedKoumoku7,
                (value) => setState(() => _selectedKoumoku7 = value)),
            _buildKoumokuDropdown('Koumoku 8', _selectedKoumoku8,
                (value) => setState(() => _selectedKoumoku8 = value)),
            _buildKoumokuDropdown('Koumoku 9', _selectedKoumoku9,
                (value) => setState(() => _selectedKoumoku9 = value)),
            _buildKoumokuDropdown('Koumoku 10', _selectedKoumoku10,
                (value) => setState(() => _selectedKoumoku10 = value)),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Combine personal information and additional info into a user object
                final user = {
                  ...widget.personalInfo,
                  'koumoku1': _selectedKoumoku1,
                  'koumoku2': _selectedKoumoku2,
                  'koumoku3': _selectedKoumoku3,
                  'koumoku4': _selectedKoumoku4,
                  'koumoku5': _selectedKoumoku5,
                  'koumoku6': _selectedKoumoku6,
                  'koumoku7': _selectedKoumoku7,
                  'koumoku8': _selectedKoumoku8,
                  'koumoku9': _selectedKoumoku9,
                  'koumoku10': _selectedKoumoku10,
                };

                // Save user data to database
                saveToDatabase(user);

                // Show a message or navigate to a success page
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registration Successful')));
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKoumokuDropdown(
      String label, String? selectedValue, Function(String?) onChanged) {
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
        items: _options.map((String option) {
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

  // Save data to your database
  void saveToDatabase(Map<String, String?> user) {
    // Implement database saving logic here
    print("Saving user data to the database: $user");
  }
}
