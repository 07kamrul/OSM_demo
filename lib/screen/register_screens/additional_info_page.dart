import 'package:flutter/material.dart';

import '../../data/models/item_list.dart';
import '../../data/repositories/item_list_repository.dart';

class AdditionalInfoPage extends StatefulWidget {
  final Map<String, String> personalInfo;

  const AdditionalInfoPage({super.key, required this.personalInfo});

  @override
  State<AdditionalInfoPage> createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends State<AdditionalInfoPage> {
  late final ItemListRepository _itemListRepository = ItemListRepository();

  String? _selectedKoumoku1;
  String? _selectedKoumoku2;
  String? _selectedKoumoku3;
  String? _selectedKoumoku4;

  List<ItemList> _itemLists = [];
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

      // Set the correct list of options for each koumoku dropdown
      setState(() {
        _koumoku1 = response.itemList.Koumoku1;
        _koumoku2 = response.itemList.Koumoku2;
        _koumoku3 = response.itemList.Koumoku3;
        _koumoku4 = response.itemList.Koumoku4;
        _isLoading = false; // Once data is fetched, stop loading
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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
                    onPressed: () {
                      // Combine personal information and additional info into a user object
                      final user = {
                        ...widget.personalInfo,
                        'koumoku1': _selectedKoumoku1,
                        'koumoku2': _selectedKoumoku2,
                        'koumoku3': _selectedKoumoku3,
                        'koumoku4': _selectedKoumoku4,
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

  // Save data to your database
  void saveToDatabase(Map<String, String?> user) {
    // Implement database saving logic here
    print("Saving user data to the database: $user");
  }
}
