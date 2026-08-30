import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../models/expense.dart';
import '../../models/group.dart';
import '../../providers/theme_controller.dart';
import '../../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final ThemeController? themeController;

  final VoidCallback? onNavigateToGroups;
  final VoidCallback? onCreateGroup;
  final VoidCallback? onAddExpense;

  const HomeScreen({
    super.key,
    this.themeController,
    this.onNavigateToGroups,
    this.onCreateGroup,
    this.onAddExpense,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<GroupData> _groups = [];
  List<ExpenseData> _expenses = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadDashboardData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _loadDashboardData();
    }
  }

  void _loadDashboardData() {
    if (!mounted) {
      return;
    }

    setState(() {
      _groups = StorageService.getGroups();
      _expenses = StorageService.getAllExpenses();
    });
  }

  Future<void> _refreshDashboard() async {
    _loadDashboardData();
  }

  double get _totalSpent {
    double total = 0;

    for (final expense in _expenses) {
      total += expense.amount;
    }

    return total;
  }

  double get _youAreOwed {
    // Your current app does not yet store a selected
    // "current user", so this cannot accurately determine
    // personal balances globally.
    //
    // For now we calculate total amount paid.

    double total = 0;

    for (final expense in _expenses) {
      total += expense.amount;
    }

    return total;
  }

  double get _youOwe {
    return 0;
  }

  List<ExpenseData> get _recentExpenses {
    final expenses = List<ExpenseData>.from(
      _expenses,
    );

    expenses.sort(
      (a, b) => b.expenseDate.compareTo(
        a.expenseDate,
      ),
    );

    return expenses.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SafeArea(
          child: DashboardContent(
            totalSpent: _totalSpent,
            youAreOwed: _youAreOwed,
            youOwe: _youOwe,
            groupsCount: _groups.length,
            expensesCount: _expenses.length,
            recentExpenses: _recentExpenses,
            onNavigateToGroups: widget.onNavigateToGroups,
            onCreateGroup: widget.onCreateGroup,
            onAddExpense: widget.onAddExpense,
          ),
        ),
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final double totalSpent;
  final double youAreOwed;
  final double youOwe;

  final int groupsCount;
  final int expensesCount;

  final List<ExpenseData> recentExpenses;

  final VoidCallback? onNavigateToGroups;
  final VoidCallback? onCreateGroup;
  final VoidCallback? onAddExpense;

  const DashboardContent({
    super.key,
    required this.totalSpent,
    required this.youAreOwed,
    required this.youOwe,
    required this.groupsCount,
    required this.expensesCount,
    required this.recentExpenses,
    this.onNavigateToGroups,
    this.onCreateGroup,
    this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              groupsCount: groupsCount,
              expensesCount: expensesCount,
            ),
            const SizedBox(height: 28),
            _BalanceHeroCard(
              totalSpent: totalSpent,
              youAreOwed: youAreOwed,
              youOwe: youOwe,
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 14),
            _QuickActions(
              onCreateGroup: onCreateGroup,
              onAddExpense: onAddExpense,
            ),
            const SizedBox(height: 28),
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 14),
            _ActivityList(
              expenses: recentExpenses,
              onTap: onNavigateToGroups,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int groupsCount;
  final int expensesCount;

  const _Header({
    required this.groupsCount,
    required this.expensesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Campus QuickSplit',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '$groupsCount groups • '
                '$expensesCount expenses',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}

class _BalanceHeroCard extends StatelessWidget {
  final double totalSpent;
  final double youAreOwed;
  final double youOwe;

  const _BalanceHeroCard({
    required this.totalSpent,
    required this.youAreOwed,
    required this.youOwe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF635BFF),
            Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL SPENDING',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '₹${totalSpent.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _BalanceItem(
                  icon: Icons.arrow_downward_rounded,
                  label: 'You are owed',
                  amount: '₹${youAreOwed.toStringAsFixed(0)}',
                ),
              ),
              const SizedBox(
                height: 46,
                child: VerticalDivider(
                  color: Colors.white24,
                ),
              ),
              Expanded(
                child: _BalanceItem(
                  icon: Icons.arrow_upward_rounded,
                  label: 'You owe',
                  amount: '₹${youOwe.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;

  const _BalanceItem({
    required this.icon,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback? onCreateGroup;
  final VoidCallback? onAddExpense;

  const _QuickActions({
    this.onCreateGroup,
    this.onAddExpense,
  });

  void _showUnavailableMessage(
    BuildContext context,
    String action,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$action is not connected to navigation yet.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'Add Expense',
            onTap: () {
              if (onAddExpense != null) {
                onAddExpense!();
              } else {
                _showUnavailableMessage(
                  context,
                  'Add Expense',
                );
              }
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _ActionCard(
            icon: Icons.group_add_outlined,
            label: 'Create Group',
            onTap: () {
              if (onCreateGroup != null) {
                onCreateGroup!();
              } else {
                _showUnavailableMessage(
                  context,
                  'Create Group',
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 24,
            horizontal: 16,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  final List<ExpenseData> expenses;
  final VoidCallback? onTap;

  const _ActivityList({
    required this.expenses,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(
                alpha: 0.12,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppTheme.primaryColor,
              ),
            ),
            title: const Text(
              'No expenses yet',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Add your first shared expense',
            ),
            trailing: const Text(
              '₹0',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: expenses.map(
          (expense) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withValues(
                  alpha: 0.12,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppTheme.primaryColor,
                ),
              ),
              title: Text(
                expense.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${expense.category} • '
                '${expense.paidBy}',
              ),
              trailing: Text(
                '₹${expense.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: onTap,
            );
          },
        ).toList(),
      ),
    );
  }
}
