import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_osm/widgets/app_bar_action_name.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';
import '../services/user_service.dart';
import '../widgets/user_card.dart';
import 'auth_screen.dart';
import 'distance_tracker_page.dart';
import 'sidebar.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<String> _userNames = [];
  List<String> _userEmails = [];
  List<String> _userProfileUrls = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Add a controller for the search field
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredUserNames = [];
  List<String> _filteredUserEmails = [];

  final AuthRepository _userRepository = AuthRepository();
  final UserService _userService = UserService();

  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchUsers();
  }

  Future<void> _fetchUser() async {
    try {
      final user = await _userService.fetchUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final List<User> users = await _userRepository.getAllUsers();
      setState(() {
        _userNames = users.map((user) => user.fullname).toList();
        _userEmails = users.map((user) => user.email).toList();
        _filteredUserNames = List.from(_userNames); // Initialize filtered list
        _filteredUserEmails = List.from(_userEmails);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user names: $e';
        _isLoading = false;
      });
    }
  }

  // Function to filter users based on search query
  void _filterUsers(String query) {
    setState(() {
      _filteredUserNames = _userNames
          .where((name) =>
              name.toLowerCase().contains(query.toLowerCase()) ||
              _userEmails[_userNames.indexOf(name)]
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
      _filteredUserEmails = _filteredUserNames
          .map((name) => _userEmails[_userNames.indexOf(name)])
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final appBarFontSize = screenWidth * 0.05; // 5% of screen width
    final paddingValue = screenWidth * 0.04; // 4% of screen width
    final searchFieldHeight = screenHeight * 0.06; // 6% of screen height
    final cardPadding = screenWidth * 0.03; // 3% of screen width

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: appBarFontSize,
          ),
        ),
        actions: [
          AppBarActionName(fontSize: appBarFontSize * 0.8),
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      drawer: Sidebar(
        onHomeTap: () {
          print("Home tapped");
        },
        onUsersTap: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => UserListScreen()));
        },
        onTrackLocationTap: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => DistanceTrackerPage()));
        },
        onSettingsTap: () {
          print("Settings tapped");
        },
        onLogoutTap: () {
          context.read<AuthBloc>().add(LogoutEvent());
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => AuthScreen()));
        },
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(paddingValue),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: Icon(Icons.search, size: appBarFontSize),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        style: TextStyle(fontSize: appBarFontSize * 0.8),
                        onChanged: (query) {
                          _filterUsers(
                              query); // Trigger filtering when text changes
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredUserNames.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: cardPadding,
                              vertical: cardPadding / 2,
                            ),
                            child: UserCard(
                              userName: _filteredUserNames[index],
                              userEmail: _filteredUserEmails[index],
                              userProfileUrl:
                                  'https://i.pravatar.cc/150?img=$index',
                              fontSize: appBarFontSize * 0.8,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
