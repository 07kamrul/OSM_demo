import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gis_osm/bloc/auth/auth_bloc.dart';
import 'package:gis_osm/bloc/auth/auth_event.dart';
import 'package:gis_osm/bloc/profile_update/profile_update_bloc.dart';
import 'package:gis_osm/bloc/profile_update/profile_update_event.dart';
import 'package:gis_osm/bloc/profile_update/profile_update_state.dart';
import 'package:gis_osm/data/models/user.dart';
import 'package:gis_osm/enum.dart';
import 'package:gis_osm/screen/auth_screen.dart';
import 'package:gis_osm/screen/change_password_screen.dart';
import 'package:gis_osm/screen/distance_tracker_screen.dart';
import 'package:gis_osm/screen/message_screens/chat_box_screen.dart';
import 'package:gis_osm/screen/sidebar.dart';
import 'package:gis_osm/screen/user_list_screen.dart';
import 'package:gis_osm/services/user_service.dart';
import 'package:gis_osm/widgets/app_bar_action_name.dart';

class ProfileUpdateScreen extends StatelessWidget {
  const ProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileUpdateBloc(
        userService: UserService(),
      )..add(FetchUser()),
      child: const _ProfileUpdateView(),
    );
  }
}

class _ProfileUpdateView extends StatefulWidget {
  const _ProfileUpdateView();

  @override
  State<_ProfileUpdateView> createState() => _ProfileUpdateViewState();
}

class _ProfileUpdateViewState extends State<_ProfileUpdateView>
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeControllers();
  }

  void _initializeControllers() {
    _fullnameController = TextEditingController();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _genderController = TextEditingController();
    _dobController = TextEditingController();
    _koumoku1Controller = TextEditingController();
    _koumoku2Controller = TextEditingController();
    _koumoku3Controller = TextEditingController();
    _koumoku4Controller = TextEditingController();
    _koumoku5Controller = TextEditingController();
    _koumoku6Controller = TextEditingController();
    _koumoku7Controller = TextEditingController();
    _koumoku8Controller = TextEditingController();
    _koumoku9Controller = TextEditingController();
    _koumoku10Controller = TextEditingController();
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
      body: BlocConsumer<ProfileUpdateBloc, ProfileUpdateState>(
        listener: (context, state) {
          if (state.user != null) {
            _updateControllers(state.user!);
          }
          if (state.updateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Profile updated: ${state.user?.fullname ?? ''}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DistanceTrackerScreen()),
            );
          } else if (state.errorMessage != null && !state.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final size = MediaQuery.of(context).size;
              final isSmallScreen =
                  size.width < AppConstants.smallScreenBreakpoint;
              final padding = size.width * AppConstants.paddingScale;
              final fontSize = size.width *
                  AppConstants.listItemFontScale *
                  (isSmallScreen ? 0.9 : 1.0);

              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.errorMessage!,
                          style:
                              TextStyle(fontSize: fontSize, color: Colors.red)),
                      SizedBox(height: padding),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<ProfileUpdateBloc>().add(FetchUser()),
                        child:
                            Text('Retry', style: TextStyle(fontSize: fontSize)),
                      ),
                    ],
                  ),
                );
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildPersonalInfoTab(
                      context, padding, fontSize, isSmallScreen),
                  _buildAdditionalInfoTab(
                      context, padding, fontSize, isSmallScreen),
                ],
              );
            },
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
            _buildDatePickerField(
              context: context,
              controller: _dobController,
              label: 'Date of Birth (YYYY-MM-DD)',
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

  Widget _buildDatePickerField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required double fontSize,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true, // prevent manual input
      decoration: InputDecoration(labelText: label),
      style: TextStyle(fontSize: fontSize),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          String formattedDate =
              "${pickedDate.toIso8601String().split('T').first}";
          controller.text = formattedDate;
        }
      },
    );
  }

  void _updateControllers(User user) {
    _fullnameController.text = user.fullname;
    _firstnameController.text = user.firstname;
    _lastnameController.text = user.lastname;
    _genderController.text = user.gender;
    _dobController.text = user.dob;
    _koumoku1Controller.text = user.koumoku1;
    _koumoku2Controller.text = user.koumoku2;
    _koumoku3Controller.text = user.koumoku3;
    _koumoku4Controller.text = user.koumoku4;
    _koumoku5Controller.text = user.koumoku5;
    _koumoku6Controller.text = user.koumoku6;
    _koumoku7Controller.text = user.koumoku7;
    _koumoku8Controller.text = user.koumoku8;
    _koumoku9Controller.text = user.koumoku9;
    _koumoku10Controller.text = user.koumoku10;
  }

  void _saveProfile(BuildContext context) {
    final state = context.read<ProfileUpdateBloc>().state;
    if (state.user == null) return;

    bool isPersonalValid = _formKeyPersonal.currentState?.validate() ?? false;
    bool isAdditionalValid =
        _formKeyAdditional.currentState?.validate() ?? false;

    if (isPersonalValid || isAdditionalValid) {
      final updatedUser = User(
        id: state.user!.id,
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
        password: state.user!.password,
        status: state.user!.status,
        profile_pic: state.user!.profile_pic,
        email: state.user!.email,
      );

      context.read<ProfileUpdateBloc>().add(UpdateUser(updatedUser));
    }
  }
}
