import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../models/expense.dart';
import '../../models/group.dart';
import '../../models/payment.dart';
import '../../services/balance_service.dart';
import '../../services/storage_service.dart';

import '../expenses/add_expense_screen.dart';
import '../expenses/expense_details_screen.dart';
import '../expenses/payment_history_screen.dart';
import 'edit_group_screen.dart';

class GroupDetailsScreen extends StatefulWidget {
  final GroupData group;

  const GroupDetailsScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late GroupData _group;

  List<ExpenseData> _expenses = [];
  List<PaymentData> _payments = [];

  bool _isLoadingExpenses = true;

  @override
  void initState() {
    super.initState();

    _group = widget.group;

    _loadData();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    final savedExpenses = StorageService.getExpenses(_group.id);

    final savedPayments = StorageService.getPayments(_group.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _expenses = savedExpenses;
      _payments = savedPayments;
      _isLoadingExpenses = false;
    });
  }

  // ============================================================
  // TOTAL SPENT
  // ============================================================

  double get _totalSpent {
    return _expenses.fold(
      0.0,
      (total, expense) => total + expense.amount,
    );
  }

  // ============================================================
  // BALANCES
  // ============================================================

  Map<String, double> get _balances {
    return BalanceService.calculateBalances(
      members: _group.members,
      expenses: _expenses,
      payments: _payments,
    );
  }

  // ============================================================
  // SETTLEMENTS
  // ============================================================

  List<SettlementData> get _settlements {
    return BalanceService.calculateSettlements(
      _balances,
    );
  }

  // ============================================================
  // EDIT GROUP
  // ============================================================

  Future<void> _openEditGroup() async {
    final updatedGroup = await Navigator.push<GroupData>(
      context,
      MaterialPageRoute(
        builder: (context) => EditGroupScreen(
          group: _group,
        ),
      ),
    );

    if (updatedGroup == null) {
      return;
    }

    await StorageService.updateGroup(
      updatedGroup,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _group = updatedGroup;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Group updated successfully',
        ),
      ),
    );
  }

  // ============================================================
  // ADD EXPENSE
  // ============================================================

  Future<void> _openAddExpense() async {
    final expense = await Navigator.push<ExpenseData>(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          group: _group,
        ),
      ),
    );

    if (expense == null) {
      return;
    }

    await StorageService.saveExpense(
      groupId: _group.id,
      expense: expense,
    );

    if (!mounted) {
      return;
    }

    await _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Expense saved successfully',
        ),
      ),
    );
  }

  // ============================================================
  // EXPENSE DETAILS
  // ============================================================

  Future<void> _openExpenseDetails(
    ExpenseData expense,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailsScreen(
          expense: expense,
          group: _group,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadData();
  }

  // ============================================================
  // DELETE EXPENSE
  // ============================================================

  Future<void> _deleteExpense(
    ExpenseData expense,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete expense?',
          ),
          content: Text(
            'Delete "${expense.title}" permanently?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await StorageService.deleteExpense(
      expense.id,
    );

    if (!mounted) {
      return;
    }

    await _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Expense deleted',
        ),
      ),
    );
  }

  // ============================================================
  // SETTLE UP
  // ============================================================

  Future<void> _settleUp(
    SettlementData settlement,
  ) async {
    String selectedMethod = 'UPI';

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  10,
                  24,
                  30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Settle Up',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${settlement.from} pays '
                      '${settlement.to}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Amount to settle',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${settlement.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Payment method',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedMethod,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.account_balance_wallet_rounded,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'UPI',
                          child: Text('UPI'),
                        ),
                        DropdownMenuItem(
                          value: 'Cash',
                          child: Text('Cash'),
                        ),
                        DropdownMenuItem(
                          value: 'Bank Transfer',
                          child: Text('Bank Transfer'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setSheetState(() {
                          selectedMethod = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                            true,
                          );
                        },
                        icon: const Icon(
                          Icons.check_circle_rounded,
                        ),
                        label: const Text(
                          'Confirm Payment',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          sheetContext,
                          false,
                        );
                      },
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final now = DateTime.now();

    final payment = PaymentData(
      id: now.microsecondsSinceEpoch.toString(),
      groupId: _group.id,
      from: settlement.from,
      to: settlement.to,
      amount: settlement.amount,
      method: selectedMethod,
      createdAt: now,
    );

    await StorageService.savePayment(
      payment,
    );

    if (!mounted) {
      return;
    }

    await _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${settlement.from} settled '
          '₹${settlement.amount.toStringAsFixed(0)} '
          'with ${settlement.to}',
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT HISTORY
  // ============================================================

  Future<void> _openPaymentHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentHistoryScreen(
          payments: _payments,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadData();
  }

  // ============================================================
  // BUILD SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 190,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_rounded,
                  ),
                  tooltip: 'Edit Group',
                  onPressed: _openEditGroup,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.history_rounded,
                  ),
                  tooltip: 'Payment History',
                  onPressed: _openPaymentHistory,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _group.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.65),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.groups_rounded,
                      size: 72,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_group.description.isNotEmpty) ...[
                      Text(
                        _group.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildOverview(context),
                    const SizedBox(height: 30),
                    _buildSectionTitle(
                      context,
                      'Balances',
                      Icons.account_balance_wallet_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildBalances(context),
                    const SizedBox(height: 30),
                    _buildSectionTitle(
                      context,
                      'Suggested Settlements',
                      Icons.currency_exchange_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildSettlements(context),
                    const SizedBox(height: 30),
                    _buildSectionTitle(
                      context,
                      'Members',
                      Icons.people_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildMembers(),
                    const SizedBox(height: 30),
                    _buildSectionTitle(
                      context,
                      'Expenses',
                      Icons.receipt_long_rounded,
                    ),
                    const SizedBox(height: 14),
                    if (_isLoadingExpenses)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_expenses.isEmpty)
                      _buildEmptyActivity(context)
                    else
                      _buildExpenseList(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverview(
    BuildContext context,
  ) {
    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            icon: Icons.currency_rupee_rounded,
            label: 'Total spent',
            value: '₹${_totalSpent.toStringAsFixed(0)}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            icon: Icons.people_outline_rounded,
            label: 'Members',
            value: '${_group.members.length}',
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BALANCES
  // ============================================================

  Widget _buildBalances(
    BuildContext context,
  ) {
    if (_expenses.isEmpty) {
      return _buildInfoCard(
        context,
        icon: Icons.account_balance_wallet_outlined,
        title: 'No balances yet',
        message: 'Add expenses to calculate everyone’s balance.',
      );
    }

    return Column(
      children: _balances.entries.map(
        (entry) {
          final member = entry.key;
          final balance = entry.value;

          final isOwed = balance > 0.01;
          final isSettled = balance.abs() <= 0.01;

          final Color balanceColor;
          final String status;

          if (isSettled) {
            balanceColor = Colors.grey;
            status = 'Settled up';
          } else if (isOwed) {
            balanceColor = Colors.green;
            status = 'Should receive money';
          } else {
            balanceColor = Colors.red;
            status = 'Owes money';
          }

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      member.isNotEmpty ? member[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          status,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isSettled
                        ? '₹0'
                        : '${isOwed ? '+' : '-'}₹${balance.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      color: balanceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // SETTLEMENTS
  // ============================================================

  Widget _buildSettlements(
    BuildContext context,
  ) {
    if (_expenses.isEmpty) {
      return _buildInfoCard(
        context,
        icon: Icons.info_outline_rounded,
        title: 'No settlements yet',
        message: 'Add expenses to see settlement suggestions.',
      );
    }

    if (_settlements.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.green.withValues(
            alpha: 0.08,
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 44,
            ),
            SizedBox(height: 10),
            Text(
              'Everyone is settled up!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _settlements.map(
        (settlement) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.15,
                    ),
                    child: const Icon(
                      Icons.currency_rupee_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${settlement.from} pays '
                          '${settlement.to}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${settlement.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      _settleUp(settlement);
                    },
                    child: const Text(
                      'Settle',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // MEMBERS
  // ============================================================

  Widget _buildMembers() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _group.members.map(
        (member) {
          return Chip(
            avatar: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(
                alpha: 0.15,
              ),
              child: Text(
                member.isNotEmpty ? member[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            label: Text(member),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 42,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY EXPENSES
  // ============================================================

  Widget _buildEmptyActivity(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 46,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 14),
          const Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add your first expense to start tracking balances.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _openAddExpense,
            icon: const Icon(Icons.add),
            label: const Text(
              'Add first expense',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPENSE LIST
  // ============================================================

  Widget _buildExpenseList(
    BuildContext context,
  ) {
    return Column(
      children: _expenses.map(
        (expense) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Dismissible(
              key: ValueKey(expense.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                await _deleteExpense(expense);

                return false;
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(
                  right: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    _openExpenseDetails(
                      expense,
                    );
                  },
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(
                            alpha: 0.45,
                          ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(
                              16,
                            ),
                          ),
                          child: Icon(
                            _getCategoryIcon(
                              expense.category,
                            ),
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                'Paid by ${expense.paidBy}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                '${expense.participants.length} people • ${expense.category}',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${expense.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _getCategoryIcon(
    String category,
  ) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;

      case 'Travel':
        return Icons.directions_car_rounded;

      case 'Shopping':
        return Icons.shopping_bag_rounded;

      case 'Rent':
        return Icons.home_rounded;

      default:
        return Icons.receipt_long_rounded;
    }
  }
}

// ============================================================
// OVERVIEW CARD
// ============================================================

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OverviewCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
