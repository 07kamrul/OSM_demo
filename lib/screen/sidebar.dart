import 'package:flutter/material.dart';
import 'package:gis_osm/common/user_storage.dart';

import '../enum.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onUsersTap;
  final VoidCallback onTrackLocationTap;
  final VoidCallback onChatBoxTap;
  final VoidCallback onChangePasswordTap; // New callback for change password
  final VoidCallback onProfileUpdateTap; // New callback for profile update
  final VoidCallback onLogoutTap;

  const Sidebar({
    super.key,
    required this.onHomeTap,
    required this.onUsersTap,
    required this.onTrackLocationTap,
    required this.onChatBoxTap,
    required this.onChangePasswordTap,
    required this.onProfileUpdateTap,
    required this.onLogoutTap,
    required void Function() onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = MediaQuery.of(context).size;
          final isSmallScreen = size.width < AppConstants.smallScreenBreakpoint;
          final isLargeScreen =
              size.width >= AppConstants.largeScreenBreakpoint;

          return _SidebarContent(
            size: size,
            isSmallScreen: isSmallScreen,
            isLargeScreen: isLargeScreen,
            onHomeTap: onHomeTap,
            onUsersTap: onUsersTap,
            onTrackLocationTap: onTrackLocationTap,
            onChatBoxTap: onChatBoxTap,
            onChangePasswordTap: onChangePasswordTap,
            onProfileUpdateTap: onProfileUpdateTap,
            onLogoutTap: onLogoutTap,
          );
        },
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final Size size;
  final bool isSmallScreen;
  final bool isLargeScreen;
  final VoidCallback onHomeTap;
  final VoidCallback onUsersTap;
  final VoidCallback onTrackLocationTap;
  final VoidCallback onChatBoxTap;
  final VoidCallback onChangePasswordTap;
  final VoidCallback onProfileUpdateTap;
  final VoidCallback onLogoutTap;

  const _SidebarContent({
    required this.size,
    required this.isSmallScreen,
    required this.isLargeScreen,
    required this.onHomeTap,
    required this.onUsersTap,
    required this.onTrackLocationTap,
    required this.onChatBoxTap,
    required this.onChangePasswordTap,
    required this.onProfileUpdateTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final headerFontSize =
        size.width * AppConstants.headerFontScale * (isSmallScreen ? 0.9 : 1.0);
    final listItemFontSize = size.width *
        AppConstants.listItemFontScale *
        (isSmallScreen ? 0.9 : 1.0);
    final iconSize = size.width *
        AppConstants.iconScale *
        (isSmallScreen
            ? 0.8
            : isLargeScreen
                ? 1.1
                : 1.0);
    final headerHeight = size.height * AppConstants.headerHeightScale;
    final padding = size.width * AppConstants.paddingScale;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildHeader(context, headerHeight, headerFontSize, padding),
        _buildMenuItem(
          context,
          icon: Icons.home,
          title: 'Home',
          onTap: onHomeTap,
          iconSize: iconSize,
          fontSize: listItemFontSize,
        ),
        _buildMenuItem(
          context,
          icon: Icons.person,
          title: 'User',
          onTap: onUsersTap,
          iconSize: iconSize,
          fontSize: listItemFontSize,
        ),
        _buildMenuItem(
          context,
          icon: Icons.chat,
          title: 'Chat box',
          onTap: onChatBoxTap,
          iconSize: iconSize,
          fontSize: listItemFontSize,
        ),
        _buildMenuItem(
          context,
          icon: Icons.location_on,
          title: 'Track Location',
          onTap: onTrackLocationTap,
          iconSize: iconSize,
          fontSize: listItemFontSize,
        ),
        _buildSettingsMenu(
          context,
          iconSize: iconSize,
          fontSize: listItemFontSize,
        ),
        _buildMenuItem(
          context,
          icon: Icons.logout,
          title: 'Logout',
          onTap: onLogoutTap,
          iconSize: iconSize,
          fontSize: listItemFontSize,
        ),
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context, double height, double fontSize, double padding) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.lightBlueAccent),
      padding: EdgeInsets.all(padding),
      child: FutureBuilder<String?>(
        future: UserStorage.getFullName(),
        builder: (context, snapshot) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                  child: CircularProgressIndicator(color: Colors.white))
            else if (snapshot.hasError)
              Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.white, fontSize: fontSize * 0.8),
              )
            else ...[
              Text(
                'Welcome',
                style: TextStyle(color: Colors.white, fontSize: fontSize * 0.8),
              ),
              Text(
                snapshot.data ?? 'Guest',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required double iconSize,
    required double fontSize,
  }) {
    return ListTile(
      leading: Icon(icon, size: iconSize),
      title: Text(
        title,
        style: TextStyle(fontSize: fontSize),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      dense: isSmallScreen,
      contentPadding: EdgeInsets.symmetric(
        horizontal: size.width *
            AppConstants.paddingScale *
            (isSmallScreen ? 0.8 : 1.0),
        vertical: isSmallScreen ? 4 : 8,
      ),
    );
  }

  Widget _buildSettingsMenu(
    BuildContext context, {
    required double iconSize,
    required double fontSize,
  }) {
    return ExpansionTile(
      leading: Icon(Icons.settings, size: iconSize),
      title: Text(
        'Settings',
        style: TextStyle(fontSize: fontSize),
      ),
      tilePadding: EdgeInsets.symmetric(
        horizontal: size.width *
            AppConstants.paddingScale *
            (isSmallScreen ? 0.8 : 1.0),
        vertical: isSmallScreen ? 4 : 8,
      ),
      childrenPadding: EdgeInsets.only(
        left: size.width *
            AppConstants.paddingScale *
            (isSmallScreen ? 1.6 : 2.0),
      ),
      children: [
        ListTile(
          title: Text(
            'Change Password',
            style: TextStyle(fontSize: fontSize * 0.9),
          ),
          onTap: () {
            Navigator.pop(context);
            onChangePasswordTap();
          },
          dense: isSmallScreen,
          contentPadding: EdgeInsets.symmetric(
            horizontal: size.width *
                AppConstants.paddingScale *
                (isSmallScreen ? 0.8 : 1.0),
            vertical: isSmallScreen ? 2 : 4,
          ),
        ),
        ListTile(
          title: Text(
            'Profile Update',
            style: TextStyle(fontSize: fontSize * 0.9),
          ),
          onTap: () {
            Navigator.pop(context);
            onProfileUpdateTap();
          },
          dense: isSmallScreen,
          contentPadding: EdgeInsets.symmetric(
            horizontal: size.width *
                AppConstants.paddingScale *
                (isSmallScreen ? 0.8 : 1.0),
            vertical: isSmallScreen ? 2 : 4,
          ),
        ),
      ],
    );
  }
}
