import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class PathFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PathFinder',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/roaming': (context) => RoamingModeScreen(),
        '/navigation': (context) => NavigationModeScreen(),
      },
    );
  }
}
