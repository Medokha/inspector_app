import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:inspector_app/core/ui/responsive.dart';
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
    final theme = Theme.of(context);
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

    final navBg = theme.navigationBarTheme.backgroundColor ?? theme.colorScheme.surface;
    final useRail = Responsive.isTablet(context) && MediaQuery.sizeOf(context).width >= Responsive.expandedWidth;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: navBg,
        systemNavigationBarIconBrightness:
            theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        body: useRail
            ? Row(
                children: <Widget>[
                  NavigationRail(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _setIndex,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: navBg,
                    indicatorColor: theme.colorScheme.secondary.withValues(alpha: 0.18),
                    destinations: <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: const Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home, color: theme.colorScheme.primary),
                        label: const Text('الرئيسية'),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.assignment_outlined),
                        selectedIcon: Icon(Icons.assignment, color: theme.colorScheme.primary),
                        label: const Text('كل المهام'),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.map_outlined),
                        selectedIcon: Icon(Icons.map, color: theme.colorScheme.primary),
                        label: const Text('خريطة المسار'),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person, color: theme.colorScheme.primary),
                        label: const Text('الملف الشخصي'),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Responsive.constrainWidth(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: pages,
                      ),
                    ),
                  ),
                ],
              )
            : Responsive.constrainWidth(
                child: IndexedStack(
                  index: _currentIndex,
                  children: pages,
                ),
              ),
        bottomNavigationBar: useRail
            ? null
            : Material(
                color: navBg,
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(bottom: 4),
                  child: NavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _setIndex,
                    backgroundColor: navBg,
                    indicatorColor: theme.colorScheme.secondary.withValues(alpha: 0.18),
                    labelBehavior: Responsive.navLabelBehavior(context),
                    destinations: <NavigationDestination>[
                      NavigationDestination(
                        icon: const Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home, color: theme.colorScheme.primary),
                        label: Responsive.isNarrow(context) ? 'رئيسية' : 'الرئيسية',
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.assignment_outlined),
                        selectedIcon: Icon(Icons.assignment, color: theme.colorScheme.primary),
                        label: Responsive.isNarrow(context) ? 'مهام' : 'كل المهام',
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.map_outlined),
                        selectedIcon: Icon(Icons.map, color: theme.colorScheme.primary),
                        label: Responsive.isNarrow(context) ? 'مسار' : 'خريطة المسار',
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person, color: theme.colorScheme.primary),
                        label: Responsive.isNarrow(context) ? 'ملفي' : 'الملف الشخصي',
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
