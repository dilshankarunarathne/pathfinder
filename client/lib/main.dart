import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/navigation.dart';
import 'screens/register.dart';
import 'screens/roam.dart';

void main() {
  var devicePre = false;

  // ignore: dead_code
  if (devicePre) {
    runApp(DevicePreview(
      //enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ));
    // ignore: dead_code
  } else {
    runApp(const MyApp());
  }
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
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
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
