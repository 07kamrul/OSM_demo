import 'package:flutter/material.dart';
import '../data/models/user.dart';
import '../enum.dart';
import '../widgets/app_bar_action_name.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04), // Responsive padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfilePicture(size),
              SizedBox(height: AppConstants.spacing),
              _buildUserName(isSmallScreen),
              SizedBox(height: AppConstants.spacing * 0.5),
              _buildUserTitle(isSmallScreen),
              SizedBox(height: AppConstants.spacing * 2),
              _buildAboutMe(size),
              SizedBox(height: AppConstants.spacing * 2),
              _buildContactInfo(isSmallScreen),
              SizedBox(height: AppConstants.spacing * 2),
              _buildSocialMedia(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.width * 0.04;

    return AppBar(
      title: Text(
        'Profile Details',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
      ),
      actions: [AppBarActionName(fontSize: fontSize * 0.8)],
      centerTitle: true,
      backgroundColor: Colors.lightBlueAccent,
    );
  }

  Widget _buildProfilePicture(Size size) {
    return CircleAvatar(
      radius: size.width * 0.15 < AppConstants.avatarRadius
          ? AppConstants.avatarRadius
          : size.width * 0.15,
      backgroundColor: Colors.grey[300],
      backgroundImage: widget.user.profile_pic.isNotEmpty
          ? NetworkImage('https://i.pravatar.cc/150')
          : null,
      child: widget.user.profile_pic.isEmpty
          ? Icon(Icons.person,
              size: AppConstants.avatarRadius, color: Colors.grey[600])
          : null,
      onBackgroundImageError: (_, __) => setState(() {
        // Fallback to default icon if image fails
      }),
    );
  }

  Widget _buildUserName(bool isSmallScreen) {
    return Text(
      widget.user.fullname.isNotEmpty ? widget.user.fullname : 'Unknown',
      style: TextStyle(
        fontSize: isSmallScreen ? 24 : 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUserTitle(bool isSmallScreen) {
    return Text(
      widget.user.hobby.isNotEmpty ? widget.user.hobby : 'No Hobby Listed',
      style: TextStyle(
        fontSize: isSmallScreen ? 14 : 16,
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildAboutMe(Size size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size.width * 0.9,
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Me',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: AppConstants.spacing * 0.5),
          Text(
            _generateAboutMeText(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5, // Improved readability
            ),
          ),
        ],
      ),
    );
  }

  String _generateAboutMeText() {
    final user = widget.user;
    return 'Hello, my name is ${user.fullname.isNotEmpty ? user.fullname : "Unknown"}. '
        'I am a ${user.gender.isNotEmpty ? user.gender : "person"}, born on '
        '${user.dob.isNotEmpty ? user.dob : "an unknown date"}, in '
        '${user.region.isNotEmpty ? user.region : "an unknown place"}. '
        'I am passionate about ${user.hobby.isNotEmpty ? user.hobby : "many things"}. '
        'My first name is ${user.firstname.isNotEmpty ? user.firstname : "not specified"} '
        'and my last name is ${user.lastname.isNotEmpty ? user.lastname : "not specified"}. '
        'Feel free to reach out to me via email at ${user.email.isNotEmpty ? user.email : "N/A"}.';
  }

  Widget _buildContactInfo(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildContactItem(
          icon: Icons.phone,
          text: '123-456-7890', // Replace with user.phone if available
          isSmallScreen: isSmallScreen,
        ),
        _buildContactItem(
          icon: Icons.email,
          text: widget.user.email.isNotEmpty ? widget.user.email : 'N/A',
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Icon(icon,
            color: Colors.blueAccent,
            size: isSmallScreen ? 24 : AppConstants.iconSize),
        SizedBox(height: AppConstants.spacing * 0.5),
        Text(
          text,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMedia() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(
          icon: Icons.facebook,
          onPressed: () {
            // Add Facebook URL or action
            debugPrint('Facebook pressed');
          },
        ),
        SizedBox(width: AppConstants.spacing),
        _buildSocialIcon(
          icon: Icons.language, // Placeholder for another social platform
          onPressed: () {
            // Add website or other action
            debugPrint('Website pressed');
          },
        ),
      ],
    );
  }

  Widget _buildSocialIcon(
      {required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      iconSize: AppConstants.iconSize,
      color: Colors.blueAccent,
      splashRadius: 24,
      tooltip: icon == Icons.facebook ? 'Facebook' : 'Website',
    );
  }
}
