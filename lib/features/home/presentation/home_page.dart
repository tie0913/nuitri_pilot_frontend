// lib/features/home/presentation/home_page.dart
import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/features/home/presentation/home_body.dart';
import 'package:nuitri_pilot_frontend/features/home/presentation/more_body.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0; // 0:home 1:account 2:more
  final _pages = const [HomeBody(), HomeBody(), MoreBody()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}