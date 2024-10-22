import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            icon: const Icon(CupertinoIcons.home),
            color: const Color(0xFF004D40), // Dark-greenish-blue color
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/roam_mode'),
            icon: const Icon(CupertinoIcons.command),
            color: const Color(0xFF004D40), // Dark-greenish-blue color
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/navigation_mode'),
            icon: const Icon(CupertinoIcons.compass),
            color: const Color(0xFF004D40), // Dark-greenish-blue color
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(CupertinoIcons.settings),
            color: const Color(0xFF004D40), // Dark-greenish-blue color
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(CupertinoIcons.person),
            color: const Color(0xFF004D40), // Dark-greenish-blue color
          ),
        ],
      ),
    );
  }
}
