import 'package:client/screens/home.dart';
import 'package:client/screens/navigation.dart';
import 'package:client/screens/roam.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pathfinder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      routes: {
        '/roam_mode': (context) => const RoamScreen(),
        '/navigation_mode': (context) => Navigation(),
      },
    );
  }
}
