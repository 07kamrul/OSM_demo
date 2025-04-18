import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_osm/common/user_storage.dart';
import 'package:gis_osm/data/models/user.dart';
import 'package:gis_osm/enum.dart';
import 'package:gis_osm/screen/sidebar.dart';
import 'package:gis_osm/screen/user_list_screen.dart';
import 'package:gis_osm/services/user_service.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../widgets/app_bar_action_name.dart';
import 'auth_screen.dart';
import 'change_password_screen.dart';
import 'distance_tracker_screen.dart';
import 'message_screens/chat_box_screen.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKeyPersonal = GlobalKey<FormState>();
  final _formKeyAdditional = GlobalKey<FormState>();

  // Controllers for Personal Information
  late TextEditingController _fullnameController;
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _genderController;
  late TextEditingController _dobController;

  // Controllers for Additional Information
  late TextEditingController _koumoku1Controller;
  late TextEditingController _koumoku2Controller;
  late TextEditingController _koumoku3Controller;
  late TextEditingController _koumoku4Controller;
  late TextEditingController _koumoku5Controller;
  late TextEditingController _koumoku6Controller;
  late TextEditingController _koumoku7Controller;
  late TextEditingController _koumoku8Controller;
  late TextEditingController _koumoku9Controller;
  late TextEditingController _koumoku10Controller;

  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = await UserStorage.getUserId();
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User ID not found in cache';
        });
        return;
      }
      final userService = UserService();
      final user = await userService.fetchUser();
      setState(() {
        _user = user;
        _userId = userId;
        _isLoading = false;
        _initializeControllers(user);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to fetch user: $e';
      });
    }
  }

  void _initializeControllers(User user) {
    _fullnameController = TextEditingController(text: user.fullname);
    _firstnameController = TextEditingController(text: user.firstname);
    _lastnameController = TextEditingController(text: user.lastname);
    _genderController = TextEditingController(text: user.gender);
    _dobController = TextEditingController(text: user.dob);
    _koumoku1Controller = TextEditingController(text: user.koumoku1);
    _koumoku2Controller = TextEditingController(text: user.koumoku2);
    _koumoku3Controller = TextEditingController(text: user.koumoku3);
    _koumoku4Controller = TextEditingController(text: user.koumoku4);
    _koumoku5Controller = TextEditingController(text: user.koumoku5);
    _koumoku6Controller = TextEditingController(text: user.koumoku6);
    _koumoku7Controller = TextEditingController(text: user.koumoku7);
    _koumoku8Controller = TextEditingController(text: user.koumoku8);
    _koumoku9Controller = TextEditingController(text: user.koumoku9);
    _koumoku10Controller = TextEditingController(text: user.koumoku10);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullnameController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _koumoku1Controller.dispose();
    _koumoku2Controller.dispose();
    _koumoku3Controller.dispose();
    _koumoku4Controller.dispose();
    _koumoku5Controller.dispose();
    _koumoku6Controller.dispose();
    _koumoku7Controller.dispose();
    _koumoku8Controller.dispose();
    _koumoku9Controller.dispose();
    _koumoku10Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = MediaQuery.of(context).size;
          final isSmallScreen = size.width < AppConstants.smallScreenBreakpoint;
          final padding = size.width * AppConstants.paddingScale;
          final fontSize = size.width *
              AppConstants.listItemFontScale *
              (isSmallScreen ? 0.9 : 1.0);

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!,
                      style: TextStyle(fontSize: fontSize, color: Colors.red)),
                  SizedBox(height: padding),
                  ElevatedButton(
                    onPressed: _fetchUserData,
                    child: Text('Retry', style: TextStyle(fontSize: fontSize)),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPersonalInfoTab(context, padding, fontSize, isSmallScreen),
              _buildAdditionalInfoTab(
                  context, padding, fontSize, isSmallScreen),
            ],
          );
        },
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
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Personal Information'),
          Tab(text: 'Additional Information'),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Sidebar(
      onHomeTap: () => _navigate(context, DistanceTrackerScreen()),
      onUsersTap: () => _navigate(context, const UserListScreen()),
      onTrackLocationTap: () => _navigate(context, DistanceTrackerScreen()),
      onChatBoxTap: () => _navigate(context, const ChatBoxScreen()),
      onChangePasswordTap: () =>
          _navigate(context, const ChangePasswordScreen()),
      onProfileUpdateTap: () => _navigate(context, const ProfileUpdateScreen()),
      onLogoutTap: () {
        context.read<AuthBloc>().add(LogoutEvent());
        _navigate(context, AuthScreen());
      },
      onSettingsTap: () {},
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildPersonalInfoTab(BuildContext context, double padding,
      double fontSize, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Form(
        key: _formKeyPersonal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _fullnameController,
              label: 'Full Name',
              fontSize: fontSize,
              validator: (value) =>
                  value!.isEmpty ? 'Full name is required' : null,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _firstnameController,
              label: 'First Name',
              fontSize: fontSize,
              validator: (value) =>
                  value!.isEmpty ? 'First name is required' : null,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _lastnameController,
              label: 'Last Name',
              fontSize: fontSize,
              validator: (value) =>
                  value!.isEmpty ? 'Last name is required' : null,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _genderController,
              label: 'Gender',
              fontSize: fontSize,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _dobController,
              label: 'Date of Birth (YYYY-MM-DD)',
              fontSize: fontSize,
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: padding * 2),
            Center(
              child: ElevatedButton(
                onPressed: () => _saveProfile(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: padding * 2,
                    vertical: padding,
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoTab(BuildContext context, double padding,
      double fontSize, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Form(
        key: _formKeyAdditional,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _koumoku1Controller,
              label: 'Koumoku 1',
              fontSize: fontSize,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _koumoku2Controller,
              label: 'Koumoku 2',
              fontSize: fontSize,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _koumoku3Controller,
              label: 'Koumoku 3',
              fontSize: fontSize,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _koumoku4Controller,
              label: 'Koumoku 4',
              fontSize: fontSize,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _koumoku5Controller,
              label: 'Koumoku 5',
              fontSize: fontSize,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _koumoku6Controller,
              label: 'Koumoku 6',
              fontSize: fontSize,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _koumoku7Controller,
              label: 'Koumoku 7',
              fontSize: fontSize,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _koumoku8Controller,
              label: 'Koumoku 8',
              fontSize: fontSize,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _koumoku9Controller,
              label: 'Koumoku 9',
              fontSize: fontSize,
            ),
            SizedBox(height: padding),
            _buildTextField(
              controller: _koumoku10Controller,
              label: 'Koumoku 10',
              fontSize: fontSize,
            ),
            SizedBox(height: padding * 2),
            Center(
              child: ElevatedButton(
                onPressed: () => _saveProfile(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: padding * 2,
                    vertical: padding,
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: fontSize, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required double fontSize,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: fontSize * 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: fontSize * 0.8,
          vertical: fontSize * 0.6,
        ),
      ),
      style: TextStyle(fontSize: fontSize * 0.9),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _saveProfile(BuildContext context) async {
    if (_user == null) return;

    bool isPersonalValid = _formKeyPersonal.currentState?.validate() ?? false;
    bool isAdditionalValid =
        _formKeyAdditional.currentState?.validate() ?? false;

    if (isPersonalValid || isAdditionalValid) {
      final updatedUser = User(
        id: _user!.id,
        fullname: _fullnameController.text,
        firstname: _firstnameController.text,
        lastname: _lastnameController.text,
        gender: _genderController.text,
        dob: _dobController.text,
        koumoku1: _koumoku1Controller.text,
        koumoku2: _koumoku2Controller.text,
        koumoku3: _koumoku3Controller.text,
        koumoku4: _koumoku4Controller.text,
        koumoku5: _koumoku5Controller.text,
        koumoku6: _koumoku6Controller.text,
        koumoku7: _koumoku7Controller.text,
        koumoku8: _koumoku8Controller.text,
        koumoku9: _koumoku9Controller.text,
        koumoku10: _koumoku10Controller.text,
        password: _user!.password,
        status: _user!.status,
        profile_pic: _user!.profile_pic,
        email: _user!.email,
      );

      try {
        final userService = UserService();
        final savedUser = await userService.updateUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated: ${savedUser.fullname}')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }
}
