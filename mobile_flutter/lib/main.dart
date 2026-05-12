import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'providers/qc_state_provider.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => QcStateProvider(),
      child: const SmartQCApp(),
    ),
  );
}

class SmartQCApp extends StatelessWidget {
  const SmartQCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart QC System',
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}