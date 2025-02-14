import 'package:flutter/material.dart';
import 'package:gis_osm/common/user_storage.dart';

class AppBarActionName extends StatelessWidget {
  final double fontSize;

  const AppBarActionName({Key? key, required this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserStorage.getFullName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        } else {
          final name = snapshot.data ?? 'Guest';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              name,
              style: TextStyle(fontSize: fontSize, color: Colors.black),
            ),
          );
        }
      },
    );
  }
}