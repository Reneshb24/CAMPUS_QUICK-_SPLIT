import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../providers/theme_controller.dart';
import '../../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeController themeController;

  const SettingsScreen({
    super.key,
    required this.themeController,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();

    _notificationsEnabled = StorageService.getNotificationsEnabled();
  }

  // ============================================================
  // EXPORT DATA
  // ============================================================

  Future<void> _exportData() async {
    final String data = StorageService.exportDataAsJson();

    await Clipboard.setData(
      ClipboardData(
        text: data,
      ),
    );

    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Data Exported',
          ),
          content: const Text(
            'Your groups, expenses and payments have been prepared and copied to your clipboard.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // STORAGE
  // ============================================================

  Future<void> _showStorage() async {
    final Map<String, int> summary = StorageService.getStorageSummary();

    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Local Storage',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Groups: ${summary['groups']}',
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Expenses: ${summary['expenses']}',
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Payments: ${summary['payments']}',
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'All data is stored locally on this device.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Close',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _confirmClearData();
              },
              child: const Text(
                'Clear Data',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CLEAR DATA CONFIRMATION
  // ============================================================

  Future<void> _confirmClearData() async {
    if (!mounted) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Clear All Data?',
          ),
          content: const Text(
            'This will permanently delete all groups, expenses and payments.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Clear',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await StorageService.clearAllData();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'All app data cleared successfully',
        ),
      ),
    );
  }

  // ============================================================
  // HELP & SUPPORT
  // ============================================================

  void _showHelpSupport() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Help & Support',
          ),
          content: const Text(
            'Campus Quick Split helps you create groups, add expenses, split bills and track payments.\n\nFor help, check your groups and expense details.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = widget.themeController.themeMode == ThemeMode.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              32,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildProfileCard(
                    context,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =============================================
                  // PREFERENCES
                  // =============================================

                  _buildSectionTitle(
                    context,
                    'Preferences',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _buildSettingsCard(
                    context,
                    children: [
                      // =========================================
                      // NOTIFICATIONS
                      // =========================================

                      SwitchListTile(
                        secondary: const Icon(
                          Icons.notifications_outlined,
                        ),
                        title: const Text(
                          'Notifications',
                        ),
                        subtitle: const Text(
                          'Get reminders and payment updates',
                        ),
                        value: _notificationsEnabled,
                        onChanged: (value) async {
                          setState(() {
                            _notificationsEnabled = value;
                          });

                          await StorageService.saveNotificationsEnabled(
                            value,
                          );

                          if (!mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? 'Notifications enabled'
                                    : 'Notifications disabled',
                              ),
                            ),
                          );
                        },
                      ),

                      const Divider(
                        height: 1,
                      ),

                      // =========================================
                      // DARK MODE
                      // =========================================

                      SwitchListTile(
                        secondary: const Icon(
                          Icons.dark_mode_outlined,
                        ),
                        title: const Text(
                          'Dark mode',
                        ),
                        subtitle: Text(
                          isDarkMode
                              ? 'Dark appearance enabled'
                              : 'Light appearance enabled',
                        ),
                        value: isDarkMode,
                        onChanged: (value) async {
                          await widget.themeController.setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =============================================
                  // DATA
                  // =============================================

                  _buildSectionTitle(
                    context,
                    'Data',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _buildSettingsCard(
                    context,
                    children: [
                      // =========================================
                      // EXPORT DATA
                      // =========================================

                      ListTile(
                        leading: const Icon(
                          Icons.download_outlined,
                        ),
                        title: const Text(
                          'Export data',
                        ),
                        subtitle: const Text(
                          'Export your groups and expenses',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: _exportData,
                      ),

                      const Divider(
                        height: 1,
                      ),

                      // =========================================
                      // STORAGE
                      // =========================================

                      ListTile(
                        leading: const Icon(
                          Icons.storage_outlined,
                        ),
                        title: const Text(
                          'Storage',
                        ),
                        subtitle: const Text(
                          'View and manage locally stored data',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: _showStorage,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =============================================
                  // ABOUT
                  // =============================================

                  _buildSectionTitle(
                    context,
                    'About',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _buildSettingsCard(
                    context,
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                        ),
                        title: const Text(
                          'Campus Quick Split',
                        ),
                        subtitle: const Text(
                          'Version 1.0.0',
                        ),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Campus Quick Split',
                            applicationVersion: '1.0.0',
                            applicationIcon: const CircleAvatar(
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                              ),
                            ),
                            children: const [
                              Text(
                                'A simple and smart way for students to split expenses with friends.',
                              ),
                            ],
                          );
                        },
                      ),

                      const Divider(
                        height: 1,
                      ),

                      // =========================================
                      // HELP
                      // =========================================

                      ListTile(
                        leading: const Icon(
                          Icons.help_outline,
                        ),
                        title: const Text(
                          'Help & Support',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: _showHelpSupport,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  Center(
                    child: Text(
                      'Made for smarter campus spending',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================

  Widget _buildProfileCard(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  'Manage your preferences',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.settings_rounded,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
