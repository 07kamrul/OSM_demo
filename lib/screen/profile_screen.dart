import 'package:flutter/material.dart';
import '../data/models/user.dart';
import '../enum.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String fullName;
  late String email;
  late String firstName;
  late String lastName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Use the User object passed via constructor
      fullName = widget.user.fullname.isNotEmpty
          ? widget.user.fullname
          : 'Unknown User';
      email = widget.user.email.isNotEmpty ? widget.user.email : 'No email';
      firstName = widget.user.firstname.isNotEmpty ? widget.user.firstname : '';
      lastName = widget.user.lastname.isNotEmpty ? widget.user.lastname : '';

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          fullName = 'Error';
          email = 'Failed to load: $e';
        });
      }
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(builder: _buildBody),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final size = MediaQuery.of(context).size;
    final padding = size.width * AppConstants.paddingScale;
    final fontSize = size.width * 0.04; // Adjusted for responsiveness

    return AppBar(
      title: Text(
        'Profile',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.lightBlueAccent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showSnackBar(
              context, 'Edit Profile not implemented yet', Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, BoxConstraints constraints) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < AppConstants.smallScreenBreakpoint;
    final isLargeScreen = size.width >= AppConstants.largeScreenBreakpoint;
    final padding = size.width * AppConstants.paddingScale;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(size, isSmallScreen, isLargeScreen, padding),
          _buildUserInfo(size, isSmallScreen, isLargeScreen, padding),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
      Size size, bool isSmallScreen, bool isLargeScreen, double padding) {
    final avatarRadius = isSmallScreen
        ? 50.0
        : isLargeScreen
            ? 80.0
            : 70.0;
    final fontSize = isSmallScreen
        ? 20.0
        : isLargeScreen
            ? 26.0
            : 24.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlueAccent, Colors.lightBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/150'),
            backgroundColor: Colors.grey.shade300,
            child: fullName == 'Error' || fullName == 'Guest'
                ? Icon(Icons.person,
                    size: avatarRadius * 1.2, color: Colors.white)
                : null,
          ),
          SizedBox(height: size.height * AppConstants.spacingScale),
          Text(
            fullName,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: size.height * AppConstants.spacingScale * 0.5),
          Text(
            email,
            style: TextStyle(
              fontSize: fontSize * 0.75,
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(
      Size size, bool isSmallScreen, bool isLargeScreen, double padding) {
    final cardWidth = isLargeScreen ? size.width * 0.6 : double.infinity;

    return Container(
      padding: EdgeInsets.all(padding),
      width: cardWidth,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Full Name', fullName, isSmallScreen),
              const Divider(height: 1),
              _buildInfoRow('First Name', firstName, isSmallScreen),
              const Divider(height: 1),
              _buildInfoRow('Last Name', lastName, isSmallScreen),
              const Divider(height: 1),
              _buildInfoRow('Email', email, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isSmallScreen) {
    final fontSize = isSmallScreen ? 16.0 : 18.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: fontSize, color: Colors.black87),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}
