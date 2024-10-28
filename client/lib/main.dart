import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/navigation.dart';
import 'screens/register.dart';
import 'screens/roam.dart';

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
      home: const SignInScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/roam_mode': (context) => const RoamModeScreen(),
        '/navigation_mode': (context) => const NavigationScreen(),
        '/sign_up': (context) => const SignUpScreen(),
      },
    );
  }
}
