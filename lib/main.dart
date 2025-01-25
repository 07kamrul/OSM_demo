import 'package:flutter/material.dart';

import 'screen/distance_tracker_page.dart';

void main() {
  runApp(const OSMDistanceApp());
}

class OSMDistanceApp extends StatelessWidget {
  const OSMDistanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Location Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DistanceTrackerPage(),
    );
  }
}
