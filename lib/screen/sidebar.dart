import 'package:flutter/material.dart';
import 'package:gis_osm/common/user_storage.dart';

class _Constants {
  static const double headerFontScale = 0.05;
  static const double listItemFontScale = 0.04;
  static const double iconScale = 0.06;
  static const double headerHeightScale = 0.15;
  static const double paddingScale = 0.05;
  static const int smallScreenBreakpoint = 400;
  static const int largeScreenBreakpoint = 600;
}

class Sidebar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onUsersTap;
  final VoidCallback onTrackLocationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const Sidebar({
    super.key,
    required this.onHomeTap,
    required this.onUsersTap,
    required this.onTrackLocationTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = MediaQuery.of(context).size;
          final isSmallScreen = size.width < _Constants.smallScreenBreakpoint;
          final isLargeScreen = size.width >= _Constants.largeScreenBreakpoint;

          return _SidebarContent(
            size: size,
            isSmallScreen: isSmallScreen,
            isLargeScreen: isLargeScreen,
            onHomeTap: onHomeTap,
            onUsersTap: onUsersTap,
            onTrackLocationTap: onTrackLocationTap,
            onSettingsTap: onSettingsTap,
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
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const _SidebarContent({
    required this.size,
    required this.isSmallScreen,
    required this.isLargeScreen,
    required this.onHomeTap,
    required this.onUsersTap,
    required this.onTrackLocationTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final headerFontSize = size.width * _Constants.headerFontScale * (isSmallScreen ? 0.9 : 1.0);
    final listItemFontSize = size.width * _Constants.listItemFontScale * (isSmallScreen ? 0.9 : 1.0);
    final iconSize = size.width * _Constants.iconScale * (isSmallScreen ? 0.8 : isLargeScreen ? 1.1 : 1.0);
    final headerHeight = size.height * _Constants.headerHeightScale;
    final padding = size.width * _Constants.paddingScale;

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
          icon: Icons.location_on,
          title: 'Track Location',
          onTap: onTrackLocationTap,
          iconSize: iconSize,
          fontSize: listItemFontSize,
        ),
        _buildMenuItem(
          context,
          icon: Icons.settings,
          title: 'Settings',
          onTap: onSettingsTap,
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

  Widget _buildHeader(BuildContext context, double height, double fontSize, double padding) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.blue),
      padding: EdgeInsets.all(padding),
      child: FutureBuilder<String?>(
        future: UserStorage.getFullName(),
        builder: (context, snapshot) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator(color: Colors.white))
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
        horizontal: size.width * _Constants.paddingScale * (isSmallScreen ? 0.8 : 1.0),
        vertical: isSmallScreen ? 4 : 8,
      ),
    );
  }
}