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
      body: SafeArea(
        child: BlocConsumer<ProfileUpdateBloc, ProfileUpdateState>(
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
            return OrientationBuilder(
              builder: (context, orientation) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final size = MediaQuery.of(context).size;
                    final isSmallScreen =
                        size.width < AppConstants.smallScreenBreakpoint;
                    final isLargeScreen =
                        size.width >= AppConstants.largeScreenBreakpoint;
                    final isLandscape = orientation == Orientation.landscape;

                    // Responsive font size (clamped between 12 and 24)
                    final fontSize = (size.width * AppConstants.fontScale)
                            .clamp(12.0, 24.0) *
                        (isSmallScreen ? 0.9 : 1.0);

                    // Responsive padding (clamped between 8 and 32)
                    final padding = (size.width * 0.04).clamp(8.0, 32.0);

                    // Responsive button size
                    final buttonWidth =
                        isSmallScreen ? size.width * 0.4 : size.width * 0.3;
                    final buttonHeight = fontSize * 2.5;

                    if (state.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.lightBlueAccent),
                        ),
                      );
                    }
                    if (state.errorMessage != null) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: size.width * 0.8,
                            maxHeight: size.height * 0.4,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.errorMessage!,
                                textAlign: TextAlign.center, // ✅ Move here
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: Colors.red,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: padding),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<ProfileUpdateBloc>()
                                    .add(FetchUser()),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(buttonWidth, buttonHeight),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: padding,
                                    vertical: padding * 0.5,
                                  ),
                                ),
                                child: Text(
                                  'Retry',
                                  style: TextStyle(fontSize: fontSize * 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPersonalInfoTab(
                          context,
                          padding,
                          fontSize,
                          isSmallScreen,
                          isLargeScreen,
                          isLandscape,
                        ),
                        _buildAdditionalInfoTab(
                          context,
                          padding,
                          fontSize,
                          isSmallScreen,
                          isLargeScreen,
                          isLandscape,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = (size.width * 0.04).clamp(14.0, 20.0);

    return AppBar(
      title: Text(
        'Profile Details',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
      actions: [
        AppBarActionName(fontSize: fontSize * 0.8),
      ],
      centerTitle: true,
      backgroundColor: Colors.lightBlueAccent,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(fontSize * 3),
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontSize: fontSize * 0.8),
          tabs: const [
            Tab(text: 'Personal Information'),
            Tab(text: 'Additional Information'),
          ],
        ),
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

  Widget _buildPersonalInfoTab(
    BuildContext context,
    double padding,
    double fontSize,
    bool isSmallScreen,
    bool isLargeScreen,
    bool isLandscape,
  ) {
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
                  minimumSize: Size(
                    isSmallScreen ? 150 : 200,
                    fontSize * 2.5,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: padding * 2,
                    vertical: padding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: fontSize * 0.9,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoTab(
    BuildContext context,
    double padding,
    double fontSize,
    bool isSmallScreen,
    bool isLargeScreen,
    bool isLandscape,
  ) {
    final textFields = [
      _buildTextField(
        controller: _koumoku1Controller,
        label: 'Koumoku 1',
        fontSize: fontSize,
      ),
      _buildTextField(
        controller: _koumoku2Controller,
        label: 'Koumoku 2',
        fontSize: fontSize,
      ),
      _buildTextField(
        controller: _koumoku3Controller,
        label: 'Koumoku 3',
        fontSize: fontSize,
      ),
      _buildTextField(
        controller: _koumoku4Controller,
        label: 'Koumoku 4',
        fontSize: fontSize,
      ),
      _buildTextField(
        controller: _koumoku5Controller,
        label: 'Koumoku 5',
        fontSize: fontSize,
      ),
      _buildTextField(
        controller: _koumoku6Controller,
        label: 'Koumoku 6',
        fontSize: fontSize,
      ),
      _buildTextField(
        controller: _koumoku7Controller,
        label: 'Koumoku 7',
        fontSize: fontSize,
      ),
      _buildTextField(
        controller: _koumoku8Controller,
        label: 'Koumoku 8',
        fontSize: fontSize,
      ),
      _buildTextField(
        controller: _koumoku9Controller,
        label: 'Koumoku 9',
        fontSize: fontSize,
      ),
      _buildTextField(
        controller: _koumoku10Controller,
        label: 'Koumoku 10',
        fontSize: fontSize,
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Form(
        key: _formKeyAdditional,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLargeScreen || isLandscape)
              GridView.count(
                crossAxisCount: isLargeScreen ? 3 : 2,
                crossAxisSpacing: padding,
                mainAxisSpacing: padding,
                childAspectRatio: isLargeScreen ? 4 : 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: textFields,
              )
            else
              Column(
                children: textFields
                    .asMap()
                    .entries
                    .map((entry) => Padding(
                          padding: EdgeInsets.only(
                              bottom: entry.key < textFields.length - 1
                                  ? padding
                                  : 0),
                          child: entry.value,
                        ))
                    .toList(),
              ),
            SizedBox(height: padding * 2),
            Center(
              child: ElevatedButton(
                onPressed: () => _saveProfile(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  minimumSize: Size(
                    isSmallScreen ? 150 : 200,
                    fontSize * 2.5,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: padding * 2,
                    vertical: padding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: fontSize * 0.9,
                    color: Colors.white,
                  ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: fontSize * 0.8,
          vertical: fontSize * 0.8,
        ),
      ),
      style: TextStyle(fontSize: fontSize * 0.9),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      minLines: 1,
      maxLines: 1,
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
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: fontSize * 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: fontSize * 0.8,
          vertical: fontSize * 0.8,
        ),
      ),
      style: TextStyle(fontSize: fontSize * 0.9),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          controller.text = "${pickedDate.toIso8601String().split('T').first}";
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

    final isPersonalValid = _formKeyPersonal.currentState?.validate() ?? false;
    final isAdditionalValid =
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
