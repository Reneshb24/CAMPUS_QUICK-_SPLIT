import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/theme/app_theme.dart';
import 'app_navigation.dart';
import 'providers/theme_controller.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive.
  await Hive.initFlutter();

  // Initialize local storage.
  await StorageService.init();

  // Initialize theme controller.
  final ThemeController themeController = ThemeController();

  await themeController.loadTheme();

  // Start application.
  runApp(
    MyApp(
      themeController: themeController,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;

  const MyApp({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (
        context,
        child,
      ) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Campus Quick Split',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: AppNavigation(
            themeController: themeController,
          ),
        );
      },
    );
  }
}
