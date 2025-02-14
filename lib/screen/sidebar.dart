import 'package:flutter/material.dart';
import 'package:gis_osm/common/user_storage.dart'; // Ensure this import is correct
import '../data/models/user.dart'; // Ensure this import is correct
import '../data/repositories/auth_repository.dart'; // Ensure this import is correct

class Sidebar extends StatefulWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onUsersTap;
  final VoidCallback onTrackLocationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const Sidebar({
    Key? key,
    required this.onHomeTap,
    required this.onUsersTap,
    required this.onTrackLocationTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  }) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    double headerFontSize = screenWidth * 0.05; // 5% of screen width
    double listItemFontSize = screenWidth * 0.04; // 4% of screen width
    double iconSize = screenWidth * 0.06; // 6% of screen width
    double drawerHeaderHeight = screenHeight * 0.15; // 15% of screen height

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Section
          FutureBuilder<String?>(
            future: UserStorage.getFullName(), // Fetch user data (ensure this method exists)
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Loading state
                return Container(
                  height: drawerHeaderHeight,
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                // Error state
                return Container(
                  height: drawerHeaderHeight,
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: headerFontSize,
                      ),
                    ),
                  ),
                );
              } else {
                // Success state
                final name = snapshot.data ?? 'Guest'; // Use the fetched name or fallback to 'Guest'
                return Container(
                  height: drawerHeaderHeight,
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        child: Text(
                          'Welcome',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: headerFontSize * 0.8,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        child: Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: headerFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),

          // Home Option
          ListTile(
            leading: Icon(Icons.home, size: iconSize),
            title: Text(
              'Home',
              style: TextStyle(fontSize: listItemFontSize),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              widget.onHomeTap();
            },
          ),

          // User Option
          ListTile(
            leading: Icon(Icons.person, size: iconSize),
            title: Text(
              'User',
              style: TextStyle(fontSize: listItemFontSize),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              widget.onUsersTap();
            },
          ),

          // Track Location Option
          ListTile(
            leading: Icon(Icons.location_on, size: iconSize),
            title: Text(
              'Track Location',
              style: TextStyle(fontSize: listItemFontSize),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              widget.onTrackLocationTap();
            },
          ),

          // Settings Option
          ListTile(
            leading: Icon(Icons.settings, size: iconSize),
            title: Text(
              'Settings',
              style: TextStyle(fontSize: listItemFontSize),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              widget.onSettingsTap();
            },
          ),

          // Logout Option
          ListTile(
            leading: Icon(Icons.logout, size: iconSize),
            title: Text(
              'Logout',
              style: TextStyle(fontSize: listItemFontSize),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              widget.onLogoutTap();
            },
          ),
        ],
      ),
    );
  }
}