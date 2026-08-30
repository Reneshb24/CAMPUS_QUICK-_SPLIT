import 'package:flutter/material.dart';

import '../models/group.dart';
import '../providers/theme_controller.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/groups/create_group_screen.dart';
import '../screens/groups/groups_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../services/storage_service.dart';

class CampusQuickSplitApp extends StatelessWidget {
  final ThemeController themeController;

  const CampusQuickSplitApp({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus QuickSplit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: AppNavigation(
        themeController: themeController,
      ),
    );
  }
}

class AppNavigation extends StatefulWidget {
  final ThemeController themeController;

  const AppNavigation({
    super.key,
    required this.themeController,
  });

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedIndex = 0;

  int _groupsRefreshKey = 0;

  // ============================================================
  // CHANGE BOTTOM NAVIGATION TAB
  // ============================================================

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ============================================================
  // OPEN CREATE GROUP
  // ============================================================

  Future<void> _openCreateGroup() async {
    final GroupData? group = await Navigator.of(context).push<GroupData>(
      MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      ),
    );

    if (group == null) {
      return;
    }

    try {
      await StorageService.saveGroup(group);

      if (!mounted) {
        return;
      }

      setState(() {
        _groupsRefreshKey++;
        _selectedIndex = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${group.name} created successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to create group: $error',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // OPEN GROUPS TAB
  // ============================================================

  void _openGroups() {
    setState(() {
      _selectedIndex = 1;
      _groupsRefreshKey++;
    });
  }

  // ============================================================
  // ADD EXPENSE
  // ============================================================

  void _openAddExpense() {
    setState(() {
      _selectedIndex = 1;
      _groupsRefreshKey++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Select a group first, then tap Add Expense.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            onNavigateToGroups: _openGroups,
            onCreateGroup: _openCreateGroup,
            onAddExpense: _openAddExpense,
          ),

          GroupsScreen(
            key: ValueKey(
              _groupsRefreshKey,
            ),
          ),

          const AnalyticsScreen(),

          // IMPORTANT: Pass ThemeController here.
          SettingsScreen(
            themeController: widget.themeController,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _changeTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
