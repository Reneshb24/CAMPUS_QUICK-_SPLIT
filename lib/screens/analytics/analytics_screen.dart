import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../models/expense.dart';
import '../../services/analytics_service.dart';
import '../../services/storage_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<ExpenseData> _expenses = [];

  String _selectedCategory = 'All';

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  // ============================================================
  // LOAD
  // ============================================================

  void _loadAnalytics() {
    setState(() {
      _expenses = StorageService.getAllExpenses();
    });
  }

  // ============================================================
  // FILTERED EXPENSES
  // ============================================================

  List<ExpenseData> get _filteredExpenses {
    return AnalyticsService.filterExpenses(
      expenses: _expenses,
      startDate: _startDate,
      endDate: _endDate,
      category: _selectedCategory,
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  List<String> get _categories {
    final categories = _expenses
        .map(
          (expense) => expense.category,
        )
        .toSet()
        .toList();

    categories.sort();

    return [
      'All',
      ...categories,
    ];
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(
              start: _startDate!,
              end: _endDate!,
            )
          : null,
    );

    if (result == null) {
      return;
    }

    setState(() {
      _startDate = result.start;
      _endDate = result.end;
    });
  }

  // ============================================================
  // CLEAR FILTERS
  // ============================================================

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _startDate = null;
      _endDate = null;
    });
  }

  // ============================================================
  // DATE LABEL
  // ============================================================

  String _dateLabel() {
    if (_startDate == null || _endDate == null) {
      return 'All time';
    }

    return '${_formatDate(_startDate!)} - '
        '${_formatDate(_endDate!)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final expenses = _filteredExpenses;

    final totalSpent = AnalyticsService.getTotalSpent(
      expenses,
    );

    final averageExpense = AnalyticsService.getAverageExpense(
      expenses,
    );

    final topSpender = AnalyticsService.getTopSpender(
      expenses,
    );

    final topSpenderAmount = AnalyticsService.getTopSpenderAmount(
      expenses,
    );

    final topCategory = AnalyticsService.getTopCategory(
      expenses,
    );

    final topCategoryAmount = AnalyticsService.getTopCategoryAmount(
      expenses,
    );

    final categoryTotals = AnalyticsService.getCategoryTotals(
      expenses,
    );

    final memberTotals = AnalyticsService.getMemberTotals(
      expenses,
    );

    final highestExpense = AnalyticsService.getHighestExpense(
      expenses,
    );

    final dailyTotals = AnalyticsService.getDailyTotals(
      expenses,
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadAnalytics();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // =================================================
            // APP BAR
            // =================================================

            SliverAppBar(
              expandedHeight: 150,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Analytics',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(
                          alpha: 0.65,
                        ),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 30,
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // =================================================
            // CONTENT
            // =================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilters(),
                    const SizedBox(
                      height: 24,
                    ),
                    if (expenses.isEmpty)
                      _buildEmptyState()
                    else ...[
                      // =========================================
                      // HERO
                      // =========================================

                      _buildHeroCard(
                        totalSpent,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // =========================================
                      // OVERVIEW
                      // =========================================

                      _buildSectionTitle(
                        'Overview',
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.receipt_long_rounded,
                              label: 'Expenses',
                              value: '${expenses.length}',
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.calculate_rounded,
                              label: 'Average',
                              value: '₹${averageExpense.toStringAsFixed(0)}',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people_rounded,
                              label: 'Spenders',
                              value: '${memberTotals.length}',
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.category_rounded,
                              label: 'Categories',
                              value: '${categoryTotals.length}',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =========================================
                      // SMART INSIGHTS
                      // =========================================

                      _buildSectionTitle(
                        'Smart Insights',
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _InsightCard(
                        icon: Icons.emoji_events_rounded,
                        title: 'Top Spender',
                        value: topSpender ?? 'No data',
                        subtitle:
                            '₹${topSpenderAmount.toStringAsFixed(0)} paid',
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _InsightCard(
                        icon: Icons.local_fire_department_rounded,
                        title: 'Highest Spending Category',
                        value: topCategory ?? 'No data',
                        subtitle:
                            '₹${topCategoryAmount.toStringAsFixed(0)} spent',
                      ),

                      if (highestExpense != null) ...[
                        const SizedBox(
                          height: 12,
                        ),
                        _InsightCard(
                          icon: Icons.trending_up_rounded,
                          title: 'Highest Expense',
                          value: highestExpense.title,
                          subtitle:
                              '₹${highestExpense.amount.toStringAsFixed(0)}',
                        ),
                      ],

                      const SizedBox(
                        height: 28,
                      ),

                      // =========================================
                      // CATEGORY
                      // =========================================

                      _buildSectionTitle(
                        'Spending by Category',
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildCategoryBreakdown(
                        categoryTotals,
                        totalSpent,
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =========================================
                      // MEMBERS
                      // =========================================

                      _buildSectionTitle(
                        'Member Spending',
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildMemberBreakdown(
                        memberTotals,
                        totalSpent,
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // =========================================
                      // DAILY TREND
                      // =========================================

                      _buildSectionTitle(
                        'Spending Trend',
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildTrendCard(
                        dailyTotals,
                      ),
                    ],
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
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    final hasFilters =
        _selectedCategory != 'All' || _startDate != null || _endDate != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_alt_rounded,
              ),
              const SizedBox(
                width: 8,
              ),
              const Expanded(
                child: Text(
                  'Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              if (hasFilters)
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text(
                    'Clear',
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(
                Icons.category_outlined,
              ),
            ),
            items: _categories.map(
              (category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              },
            ).toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(
            height: 12,
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(
                Icons.calendar_month_rounded,
              ),
              label: Text(_dateLabel()),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHeroCard(
    double totalSpent,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(
              alpha: 0.70,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(
              alpha: 0.25,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'TOTAL SPENDING',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 18,
          ),
          Text(
            '₹${totalSpent.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            _dateLabel(),
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // CATEGORY BREAKDOWN
  // ============================================================

  Widget _buildCategoryBreakdown(
    Map<String, double> categories,
    double total,
  ) {
    final sorted = categories.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(
          a.value,
        ),
      );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: sorted.map(
          (entry) {
            final percentage = total <= 0 ? 0.0 : entry.value / total;

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 18,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '₹${entry.value.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 10,
                      backgroundColor: Colors.grey.withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  // ============================================================
  // MEMBER BREAKDOWN
  // ============================================================

  Widget _buildMemberBreakdown(
    Map<String, double> members,
    double total,
  ) {
    final sorted = members.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(
          a.value,
        ),
      );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: sorted.map(
          (entry) {
            final percentage = total <= 0 ? 0.0 : entry.value / total;

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 18,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      entry.key.isNotEmpty ? entry.key[0].toUpperCase() : '?',
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 8,
                            backgroundColor: Colors.grey.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    '₹${entry.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  // ============================================================
  // TREND
  // ============================================================

  Widget _buildTrendCard(
    Map<DateTime, double> totals,
  ) {
    final entries = totals.entries.toList()
      ..sort(
        (a, b) => a.key.compareTo(
          b.key,
        ),
      );

    if (entries.isEmpty) {
      return const SizedBox();
    }

    final highest = entries
        .map(
          (entry) => entry.value,
        )
        .reduce(
          (a, b) => a > b ? a : b,
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: entries.take(10).map(
          (entry) {
            final progress = highest <= 0 ? 0.0 : entry.value / highest;

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 14,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      _formatDate(
                        entry.key,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '₹${entry.value.toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 100,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'No analytics yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Add expenses to groups to see your spending insights.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.55,
            ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(
            height: 4,
          ),
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

// ============================================================
// INSIGHT CARD
// ============================================================

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(
                16,
              ),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
