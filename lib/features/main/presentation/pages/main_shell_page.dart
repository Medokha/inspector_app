import 'package:flutter/material.dart';

import 'package:inspector_app/features/home/presentation/pages/home_page.dart';
import 'package:inspector_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:inspector_app/features/profile/presentation/pages/profile_page.dart';
import 'package:inspector_app/features/route_map/presentation/pages/route_map_page.dart';
import 'package:inspector_app/features/settings/presentation/pages/settings_page.dart';
import 'package:inspector_app/features/tasks/presentation/pages/tasks_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  void _setIndex(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(
        onNavigateToTab: _setIndex,
        onOpenNotifications: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          );
        },
      ),
      const TasksPage(),
      const RouteMapPage(),
      ProfilePage(
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        },
      ),
    ];

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _setIndex,
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF006D77)),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: Color(0xFF006D77)),
            label: 'كل المهام',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: Color(0xFF006D77)),
            label: 'خريطة المسار',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF006D77)),
            label: 'الملف الشخصي',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
    );
  }
}
