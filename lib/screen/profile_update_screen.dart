import 'package:flutter/material.dart';

class ProfileUpdateScreen extends StatelessWidget {
  const ProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Update')),
      body: const Center(
        child: Text('Profile Update Screen'),
      ),
    );
  }
}
