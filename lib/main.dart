import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AdaptiveFocusStudioApp(),
    ),
  );
}

class AdaptiveFocusStudioApp extends StatelessWidget {
  const AdaptiveFocusStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adaptive Focus Studio',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const DashboardScreen(),
    );
  }
}