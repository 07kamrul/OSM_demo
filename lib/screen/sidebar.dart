import 'package:flutter/material.dart';

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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Section
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),

          // Home Option
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              onHomeTap();
            },
          ),

          // Track Location Option
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Track Location'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              onTrackLocationTap();
            },
          ),

          // Settings Option
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              onSettingsTap();
            },
          ),

          // Logout Option
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
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