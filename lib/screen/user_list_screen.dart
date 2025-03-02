import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_osm/widgets/app_bar_action_name.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';
import '../enum.dart';
import '../services/user_service.dart';
import '../widgets/user_card.dart';
import 'auth_screen.dart';
import 'chat_screen.dart';
import 'distance_tracker_page.dart';
import 'sidebar.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late final AuthRepository _userRepository = AuthRepository();
  late final UserService _userService = UserService();
  late final TextEditingController _searchController = TextEditingController();

  // Use a single list of User objects instead of separate lists
  List<User> _users = [];
  List<User> _filteredUsers = [];
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _initializeData() async {
    try {
      final results = await Future.wait([
        _userService.fetchUser(),
        _userRepository.getAllUsers(),
      ]);
      if (mounted) {
        setState(() {
          _currentUser = results[0] as User;
          _users = results[1] as List<User>;
          _filteredUsers = List.from(_users);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _filterUsers() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredUsers = _users
            .where((user) =>
                user.fullname.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_filterUsers)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final isLargeScreen = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: _buildAppBar(size),
          drawer: isLargeScreen ? null : _buildDrawer(context),
          body: Stack(
            children: [
              if (isLargeScreen) _buildSidebar(context, size),
              _buildBody(size, constraints),
              if (_isLoading) _buildLoadingIndicator(),
              if (_errorMessage != null) _buildErrorMessage(size),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(Size size) {
    final appBarFontSize = size.width * AppConstants.appBarFontScale;
    return AppBar(
      title: Text(
        'User List',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: appBarFontSize,
        ),
      ),
      actions: [AppBarActionName(fontSize: appBarFontSize * 0.8)],
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(child: _buildSidebarContent(context));
  }

  Widget _buildSidebar(BuildContext context, Size size) {
    return Container(
      width: size.width * 0.25,
      color: Colors.grey[100],
      child: _buildSidebarContent(context),
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Sidebar(
      onHomeTap: () => _navigateTo(context, const DistanceTrackerPage()),
      onUsersTap: () => _navigateTo(context, const UserListScreen()),
      onTrackLocationTap: () =>
          _navigateTo(context, const DistanceTrackerPage()),
      // onChatBoxTap: () => Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //         builder: (_) => ChatScreen(senderId: 1, receiverId: 1))),
      onSettingsTap: () => debugPrint("Settings tapped"),
      onLogoutTap: () {
        context.read<AuthBloc>().add(LogoutEvent());
        _navigateTo(context, AuthScreen());
      },
    );
  }

  Widget _buildBody(Size size, BoxConstraints constraints) {
    final paddingValue = size.width * AppConstants.paddingScale;
    final appBarFontSize = size.width * AppConstants.appBarFontScale;
    final isSmallScreen = size.width < 400;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(paddingValue),
          child: _buildSearchField(size, appBarFontSize),
        ),
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) => _buildUserCard(
              size,
              _filteredUsers[index],
              index,
              isSmallScreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(Size size, double appBarFontSize) {
    return TextField(
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
    );
  }

  Widget _buildUserCard(Size size, User user, int index, bool isSmallScreen) {
    final cardPadding = size.width * AppConstants.cardPaddingScale;
    final fontSize = (size.width * AppConstants.appBarFontScale) * 0.8;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: cardPadding,
        vertical: cardPadding * 0.5,
      ),
      child: UserCard(
        userName: user.fullname,
        userEmail: user.email,
        userProfileUrl: 'https://i.pravatar.cc/150?img=$index',
        fontSize: isSmallScreen ? fontSize * 0.9 : fontSize,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black26,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorMessage(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Text(
          _errorMessage!,
          style: TextStyle(
            fontSize: size.width * AppConstants.appBarFontScale * 0.8,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }
}
