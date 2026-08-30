import '../models/expense.dart';

class AnalyticsService {
  // ============================================================
  // TOTAL SPENT
  // ============================================================

  static double getTotalSpent(
    List<ExpenseData> expenses,
  ) {
    return expenses.fold(
      0.0,
      (total, expense) => total + expense.amount,
    );
  }

  // ============================================================
  // AVERAGE EXPENSE
  // ============================================================

  static double getAverageExpense(
    List<ExpenseData> expenses,
  ) {
    if (expenses.isEmpty) {
      return 0;
    }

    return getTotalSpent(expenses) / expenses.length;
  }

  // ============================================================
  // CATEGORY TOTALS
  // ============================================================

  static Map<String, double> getCategoryTotals(
    List<ExpenseData> expenses,
  ) {
    final totals = <String, double>{};

    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }

  // ============================================================
  // MEMBER TOTALS
  //
  // Calculates how much each member actually paid.
  // ============================================================

  static Map<String, double> getMemberTotals(
    List<ExpenseData> expenses,
  ) {
    final totals = <String, double>{};

    for (final expense in expenses) {
      totals[expense.paidBy] = (totals[expense.paidBy] ?? 0) + expense.amount;
    }

    return totals;
  }

  // ============================================================
  // TOP SPENDER
  // ============================================================

  static String? getTopSpender(
    List<ExpenseData> expenses,
  ) {
    final totals = getMemberTotals(expenses);

    if (totals.isEmpty) {
      return null;
    }

    String? topMember;
    double highestAmount = 0;

    for (final entry in totals.entries) {
      if (entry.value > highestAmount) {
        highestAmount = entry.value;
        topMember = entry.key;
      }
    }

    return topMember;
  }

  // ============================================================
  // TOP SPENDER AMOUNT
  // ============================================================

  static double getTopSpenderAmount(
    List<ExpenseData> expenses,
  ) {
    final totals = getMemberTotals(expenses);

    if (totals.isEmpty) {
      return 0;
    }

    double highestAmount = 0;

    for (final amount in totals.values) {
      if (amount > highestAmount) {
        highestAmount = amount;
      }
    }

    return highestAmount;
  }

  // ============================================================
  // TOP CATEGORY
  // ============================================================

  static String? getTopCategory(
    List<ExpenseData> expenses,
  ) {
    final totals = getCategoryTotals(expenses);

    if (totals.isEmpty) {
      return null;
    }

    String? topCategory;
    double highestAmount = 0;

    for (final entry in totals.entries) {
      if (entry.value > highestAmount) {
        highestAmount = entry.value;
        topCategory = entry.key;
      }
    }

    return topCategory;
  }

  // ============================================================
  // TOP CATEGORY AMOUNT
  // ============================================================

  static double getTopCategoryAmount(
    List<ExpenseData> expenses,
  ) {
    final totals = getCategoryTotals(expenses);

    if (totals.isEmpty) {
      return 0;
    }

    double highestAmount = 0;

    for (final amount in totals.values) {
      if (amount > highestAmount) {
        highestAmount = amount;
      }
    }

    return highestAmount;
  }

  // ============================================================
  // FILTER BY DATE RANGE
  // ============================================================

  static List<ExpenseData> filterByDateRange({
    required List<ExpenseData> expenses,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return expenses.where((expense) {
      final date = expense.expenseDate;

      if (startDate != null &&
          date.isBefore(
            DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
            ),
          )) {
        return false;
      }

      if (endDate != null &&
          date.isAfter(
            DateTime(
              endDate.year,
              endDate.month,
              endDate.day,
              23,
              59,
              59,
            ),
          )) {
        return false;
      }

      return true;
    }).toList();
  }

  // ============================================================
  // FILTER BY CATEGORY
  // ============================================================

  static List<ExpenseData> filterByCategory({
    required List<ExpenseData> expenses,
    String? category,
  }) {
    if (category == null || category == 'All') {
      return expenses;
    }

    return expenses
        .where(
          (expense) => expense.category == category,
        )
        .toList();
  }

  // ============================================================
  // DATE RANGE + CATEGORY FILTER
  // ============================================================

  static List<ExpenseData> filterExpenses({
    required List<ExpenseData> expenses,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) {
    var filtered = filterByDateRange(
      expenses: expenses,
      startDate: startDate,
      endDate: endDate,
    );

    filtered = filterByCategory(
      expenses: filtered,
      category: category,
    );

    return filtered;
  }

  // ============================================================
  // DAILY TOTALS
  // ============================================================

  static Map<DateTime, double> getDailyTotals(
    List<ExpenseData> expenses,
  ) {
    final totals = <DateTime, double>{};

    for (final expense in expenses) {
      final date = DateTime(
        expense.expenseDate.year,
        expense.expenseDate.month,
        expense.expenseDate.day,
      );

      totals[date] = (totals[date] ?? 0) + expense.amount;
    }

    return totals;
  }

  // ============================================================
  // MONTHLY TOTALS
  // ============================================================

  static Map<String, double> getMonthlyTotals(
    List<ExpenseData> expenses,
  ) {
    final totals = <String, double>{};

    for (final expense in expenses) {
      final key = '${expense.expenseDate.year}-'
          '${expense.expenseDate.month.toString().padLeft(2, '0')}';

      totals[key] = (totals[key] ?? 0) + expense.amount;
    }

    return totals;
  }

  // ============================================================
  // HIGHEST EXPENSE
  // ============================================================

  static ExpenseData? getHighestExpense(
    List<ExpenseData> expenses,
  ) {
    if (expenses.isEmpty) {
      return null;
    }

    ExpenseData highest = expenses.first;

    for (final expense in expenses) {
      if (expense.amount > highest.amount) {
        highest = expense;
      }
    }

    return highest;
  }

  // ============================================================
  // EXPENSE COUNT BY CATEGORY
  // ============================================================

  static Map<String, int> getCategoryCounts(
    List<ExpenseData> expenses,
  ) {
    final counts = <String, int>{};

    for (final expense in expenses) {
      counts[expense.category] = (counts[expense.category] ?? 0) + 1;
    }

    return counts;
  }
}
