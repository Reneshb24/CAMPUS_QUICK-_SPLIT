import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../models/expense.dart';
import '../../models/group.dart';
import '../../services/storage_service.dart';
import 'edit_expense_screen.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final ExpenseData expense;
  final GroupData group;

  const ExpenseDetailsScreen({
    super.key,
    required this.expense,
    required this.group,
  });

  // ============================================================
  // EDIT EXPENSE
  // ============================================================

  Future<void> _editExpense(
    BuildContext context,
  ) async {
    final updatedExpense = await Navigator.push<ExpenseData>(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(
          group: group,
          expense: expense,
        ),
      ),
    );

    if (updatedExpense == null) {
      return;
    }

    await StorageService.updateExpense(
      groupId: group.id,
      expense: updatedExpense,
    );

    if (!context.mounted) {
      return;
    }

    Navigator.pop(
      context,
      updatedExpense,
    );
  }

  // ============================================================
  // SPLIT TYPE LABEL
  // ============================================================

  String get _splitTypeLabel {
    switch (expense.splitType) {
      case 'custom':
        return 'Custom Split';

      case 'percentage':
        return 'Percentage Split';

      case 'ratio':
        return 'Ratio Split';

      default:
        return 'Equal Split';
    }
  }

  // ============================================================
  // SPLIT TYPE ICON
  // ============================================================

  IconData get _splitTypeIcon {
    switch (expense.splitType) {
      case 'custom':
        return Icons.edit_note_rounded;

      case 'percentage':
        return Icons.percent_rounded;

      case 'ratio':
        return Icons.pie_chart_rounded;

      default:
        return Icons.horizontal_distribute_rounded;
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(
    DateTime date,
  ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  // ============================================================
  // CALCULATE CUSTOM SPLIT TOTAL
  // ============================================================

  double get _customSplitTotal {
    double total = 0;

    for (final participant in expense.participants) {
      total += expense.customSplits[participant] ?? 0;
    }

    return total;
  }

  // ============================================================
  // CALCULATE PERCENTAGE TOTAL
  // ============================================================

  double get _percentageTotal {
    double total = 0;

    for (final participant in expense.participants) {
      total += expense.percentageSplits[participant] ?? 0;
    }

    return total;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final participantCount = expense.participants.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Details',
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Expense',
            icon: const Icon(
              Icons.edit_rounded,
            ),
            onPressed: () {
              _editExpense(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // EXPENSE HEADER
            // =====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      _getCategoryIcon(
                        expense.category,
                      ),
                      color: AppTheme.primaryColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    expense.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    expense.category,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '₹${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // PAYMENT INFORMATION
            // =====================================================

            _buildSectionTitle(
              context,
              'Payment Information',
              Icons.payment_rounded,
            ),

            const SizedBox(height: 14),

            _buildInfoCard(
              context,
              icon: Icons.person_rounded,
              label: 'Paid by',
              value: expense.paidBy,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.group_rounded,
              label: 'Group',
              value: group.name,
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              context,
              icon: Icons.calendar_month_rounded,
              label: 'Expense date',
              value: _formatDate(
                expense.expenseDate,
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // SPLIT DETAILS
            // =====================================================

            _buildSectionTitle(
              context,
              'Split Details',
              Icons.pie_chart_rounded,
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  // =================================================
                  // SPLIT TYPE
                  // =================================================

                  Row(
                    children: [
                      Icon(
                        _splitTypeIcon,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _splitTypeLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Divider(
                    color: Colors.grey.shade300,
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // PARTICIPANT COUNT
                  // =================================================

                  Row(
                    children: [
                      const Icon(
                        Icons.people_rounded,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$participantCount participants',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // =================================================
                  // EQUAL SPLIT
                  // =================================================

                  if (expense.splitType == 'equal') ...[
                    const SizedBox(height: 18),
                    Divider(
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Each person pays',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '₹${expense.splitAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // =================================================
                  // CUSTOM SPLIT
                  // =================================================

                  if (expense.splitType == 'custom') ...[
                    const SizedBox(height: 18),
                    Divider(
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Split method',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Text(
                          'Individual amounts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total assigned',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '₹${_customSplitTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // =================================================
                  // PERCENTAGE SPLIT
                  // =================================================

                  if (expense.splitType == 'percentage') ...[
                    const SizedBox(height: 18),
                    Divider(
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Split method',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Text(
                          'Percentage based',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total percentage',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${_percentageTotal.toStringAsFixed(2)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // =================================================
                  // RATIO SPLIT
                  // =================================================

                  if (expense.splitType == 'ratio') ...[
                    const SizedBox(height: 18),
                    Divider(
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total ratio',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          expense.totalRatio.toStringAsFixed(2),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // PARTICIPANTS
            // =====================================================

            _buildSectionTitle(
              context,
              'Participants',
              Icons.people_alt_rounded,
            ),

            const SizedBox(height: 14),

            ...expense.participants.map(
              (participant) {
                final memberAmount = expense.amountForMember(
                  participant,
                );

                String extraInfo;

                // ===============================================
                // PERCENTAGE
                // ===============================================

                if (expense.splitType == 'percentage') {
                  final percentage = expense.percentageSplits[participant] ?? 0;

                  extraInfo = '${percentage.toStringAsFixed(2)}%';
                }

                // ===============================================
                // RATIO
                // ===============================================

                else if (expense.splitType == 'ratio') {
                  final ratio = expense.ratioSplits[participant] ?? 0;

                  extraInfo = 'Ratio ${ratio.toStringAsFixed(2)}';
                }

                // ===============================================
                // CUSTOM
                // ===============================================

                else if (expense.splitType == 'custom') {
                  final customAmount = expense.customSplits[participant] ?? 0;

                  extraInfo = 'Custom: ₹${customAmount.toStringAsFixed(2)}';
                }

                // ===============================================
                // EQUAL
                // ===============================================

                else {
                  extraInfo = 'Equal share';
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
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.15,
                          ),
                          child: Text(
                            participant.isNotEmpty
                                ? participant[0].toUpperCase()
                                : '?',
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
                                participant,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                extraInfo,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${memberAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // =====================================================
            // RECORD INFORMATION
            // =====================================================

            _buildSectionTitle(
              context,
              'Record Information',
              Icons.info_outline_rounded,
            ),

            const SizedBox(height: 14),

            _buildInfoCard(
              context,
              icon: Icons.access_time_rounded,
              label: 'Created',
              value: _formatDate(
                expense.createdAt,
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // EDIT BUTTON
            // =====================================================

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  _editExpense(context);
                },
                icon: const Icon(
                  Icons.edit_rounded,
                ),
                label: const Text(
                  'Edit Expense',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
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
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
