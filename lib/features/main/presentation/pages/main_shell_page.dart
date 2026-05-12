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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _setIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'كل المهام',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'خريطة المسار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'الملف الشخصي',
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
    );
  }
}
