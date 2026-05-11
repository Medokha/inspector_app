import 'package:flutter/material.dart';

import 'package:inspector_app/core/theme/app_theme.dart';
import 'package:inspector_app/features/counter/presentation/pages/counter_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspector App',
      theme: AppTheme.light,
      home: const CounterPage(),
    );
  }
}
