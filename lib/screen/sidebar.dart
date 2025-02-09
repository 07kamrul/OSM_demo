import 'package:flutter/material.dart';
import 'package:gis_osm/common/user_storage.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onTrackLocationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const Sidebar({
    Key? key,
    required this.onHomeTap,
    required this.onTrackLocationTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    double headerFontSize = screenWidth * 0.05; // 5% of screen width
    double listItemFontSize = screenWidth * 0.04; // 4% of screen width
    double iconSize = screenWidth * 0.06; // 6% of screen width
    double drawerHeaderHeight = screenHeight * 0.2; // 20% of screen height

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Section
          FutureBuilder<String?>(
            future: UserStorage.getEmail(), // Fetch the email asynchronously
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while fetching the email
                return Container(
                  height: drawerHeaderHeight,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                // Handle errors gracefully
                return Container(
                  height: drawerHeaderHeight,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
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
                // Display the email if available
                final email = snapshot.data ?? 'Guest'; // Default to "Guest" if email is null
                return Container(
                  height: drawerHeaderHeight,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
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
                          email,
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
              onHomeTap();
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
              onTrackLocationTap();
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
              onSettingsTap();
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
              onLogoutTap();
            },
          ),
        ],
      ),
    );
  }
}