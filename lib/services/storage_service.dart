import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense.dart';
import '../models/group.dart';
import '../models/payment.dart';

class StorageService {
  static const String _groupsBoxName = 'groups_box';
  static const String _expensesBoxName = 'expenses_box';
  static const String _paymentsBoxName = 'payments_box';
  static const String _settingsBoxName = 'settings_box';

  static Box? _groupsBox;
  static Box? _expensesBox;
  static Box? _paymentsBox;
  static Box? _settingsBox;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  static Future<void> init() async {
    _groupsBox ??= await Hive.openBox(
      _groupsBoxName,
    );

    _expensesBox ??= await Hive.openBox(
      _expensesBoxName,
    );

    _paymentsBox ??= await Hive.openBox(
      _paymentsBoxName,
    );

    _settingsBox ??= await Hive.openBox(
      _settingsBoxName,
    );
  }

  // ============================================================
  // GROUPS
  // ============================================================

  static Future<void> saveGroup(
    GroupData group,
  ) async {
    if (_groupsBox == null) {
      return;
    }

    await _groupsBox!.put(
      group.id,
      {
        'id': group.id,
        'name': group.name,
        'description': group.description,
        'members': List<String>.from(
          group.members,
        ),
        'createdAt': group.createdAt.toIso8601String(),
      },
    );
  }

  static List<GroupData> getGroups() {
    if (_groupsBox == null) {
      return [];
    }

    final groups = <GroupData>[];

    for (final value in _groupsBox!.values) {
      if (value is! Map) {
        continue;
      }

      final data = Map<dynamic, dynamic>.from(value);

      final createdAt = _readDateTime(
        data['createdAt'],
        fallback: DateTime.now(),
      );

      groups.add(
        GroupData(
          id: data['id']?.toString() ?? '',
          name: data['name']?.toString() ?? '',
          description: data['description']?.toString() ?? '',
          members: _readStringList(
            data['members'],
          ),
          createdAt: createdAt,
        ),
      );
    }

    groups.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return groups;
  }

  static Future<void> updateGroup(
    GroupData group,
  ) async {
    await saveGroup(group);
  }

  static Future<void> deleteGroup(
    String groupId,
  ) async {
    if (_groupsBox == null || _expensesBox == null || _paymentsBox == null) {
      return;
    }

    await _groupsBox!.delete(
      groupId,
    );

    // Delete all expenses belonging to the group.
    final expenseKeys = <dynamic>[];

    for (final key in _expensesBox!.keys) {
      final value = _expensesBox!.get(key);

      if (value is Map && value['groupId']?.toString() == groupId) {
        expenseKeys.add(key);
      }
    }

    for (final key in expenseKeys) {
      await _expensesBox!.delete(key);
    }

    // Delete all payments belonging to the group.
    final paymentKeys = <dynamic>[];

    for (final key in _paymentsBox!.keys) {
      final value = _paymentsBox!.get(key);

      if (value is Map && value['groupId']?.toString() == groupId) {
        paymentKeys.add(key);
      }
    }

    for (final key in paymentKeys) {
      await _paymentsBox!.delete(key);
    }
  }

  // ============================================================
  // EXPENSE MAP
  // ============================================================

  static Map<String, dynamic> _expenseToMap({
    required String groupId,
    required ExpenseData expense,
  }) {
    return {
      'id': expense.id,
      'groupId': groupId,
      'title': expense.title,
      'amount': expense.amount,
      'category': expense.category,

      // Legacy single payer.
      'paidBy': expense.paidBy,

      // Multi-payer splits.
      'payerSplits': Map<String, double>.from(
        expense.payerSplits,
      ),

      'participants': List<String>.from(
        expense.participants,
      ),

      'expenseDate': expense.expenseDate.toIso8601String(),

      'createdAt': expense.createdAt.toIso8601String(),

      'splitType': expense.splitType,

      'customSplits': Map<String, double>.from(
        expense.customSplits,
      ),

      'percentageSplits': Map<String, double>.from(
        expense.percentageSplits,
      ),

      'ratioSplits': Map<String, double>.from(
        expense.ratioSplits,
      ),
    };
  }

  // ============================================================
  // SAVE EXPENSE
  // ============================================================

  static Future<void> saveExpense({
    required String groupId,
    required ExpenseData expense,
  }) async {
    if (_expensesBox == null) {
      return;
    }

    await _expensesBox!.put(
      expense.id,
      _expenseToMap(
        groupId: groupId,
        expense: expense,
      ),
    );
  }

  // ============================================================
  // UPDATE EXPENSE
  // ============================================================

  static Future<void> updateExpense({
    required String groupId,
    required ExpenseData expense,
  }) async {
    if (_expensesBox == null) {
      return;
    }

    await _expensesBox!.put(
      expense.id,
      _expenseToMap(
        groupId: groupId,
        expense: expense,
      ),
    );
  }

  // ============================================================
  // GET EXPENSES FOR GROUP
  // ============================================================

  static List<ExpenseData> getExpenses(
    String groupId,
  ) {
    if (_expensesBox == null) {
      return [];
    }

    final expenses = <ExpenseData>[];

    for (final value in _expensesBox!.values) {
      if (value is! Map) {
        continue;
      }

      final data = Map<dynamic, dynamic>.from(
        value,
      );

      if (data['groupId']?.toString() != groupId) {
        continue;
      }

      expenses.add(
        _expenseFromMap(data),
      );
    }

    expenses.sort(
      (a, b) => b.expenseDate.compareTo(
        a.expenseDate,
      ),
    );

    return expenses;
  }

  // ============================================================
  // GET ALL EXPENSES
  // ============================================================

  static List<ExpenseData> getAllExpenses() {
    if (_expensesBox == null) {
      return [];
    }

    final expenses = <ExpenseData>[];

    for (final value in _expensesBox!.values) {
      if (value is! Map) {
        continue;
      }

      expenses.add(
        _expenseFromMap(
          Map<dynamic, dynamic>.from(
            value,
          ),
        ),
      );
    }

    expenses.sort(
      (a, b) => b.expenseDate.compareTo(
        a.expenseDate,
      ),
    );

    return expenses;
  }

  // ============================================================
  // GET SINGLE EXPENSE
  // ============================================================

  static ExpenseData? getExpense(
    String expenseId,
  ) {
    if (_expensesBox == null) {
      return null;
    }

    final value = _expensesBox!.get(
      expenseId,
    );

    if (value is! Map) {
      return null;
    }

    return _expenseFromMap(
      Map<dynamic, dynamic>.from(value),
    );
  }

  // ============================================================
  // READ EXPENSE
  // ============================================================

  static ExpenseData _expenseFromMap(
    Map<dynamic, dynamic> data,
  ) {
    final createdAt = _readDateTime(
      data['createdAt'],
      fallback: DateTime.now(),
    );

    final expenseDate = _readDateTime(
      data['expenseDate'],
      fallback: createdAt,
    );

    return ExpenseData(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      amount: _readDouble(
        data['amount'],
      ),
      category: data['category']?.toString() ?? 'Other',

      // Backward compatibility.
      paidBy: data['paidBy']?.toString() ?? '',

      // Multi-payer support.
      payerSplits: _readDoubleMap(
        data['payerSplits'],
      ),

      participants: _readStringList(
        data['participants'],
      ),

      expenseDate: expenseDate,
      createdAt: createdAt,

      splitType: data['splitType']?.toString() ?? 'equal',

      customSplits: _readDoubleMap(
        data['customSplits'],
      ),

      percentageSplits: _readDoubleMap(
        data['percentageSplits'],
      ),

      ratioSplits: _readDoubleMap(
        data['ratioSplits'],
      ),
    );
  }

  // ============================================================
  // READ DOUBLE MAP
  // ============================================================

  static Map<String, double> _readDoubleMap(
    dynamic value,
  ) {
    final result = <String, double>{};

    if (value is! Map) {
      return result;
    }

    for (final entry in value.entries) {
      result[entry.key.toString()] = _readDouble(
        entry.value,
      );
    }

    return result;
  }

  // ============================================================
  // READ STRING LIST
  // ============================================================

  static List<String> _readStringList(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .map(
          (item) => item.toString(),
        )
        .toList();
  }

  // ============================================================
  // READ DOUBLE
  // ============================================================

  static double _readDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  // ============================================================
  // READ DATE TIME SAFELY
  // ============================================================

  static DateTime _readDateTime(
    dynamic value, {
    required DateTime fallback,
  }) {
    if (value == null) {
      return fallback;
    }

    return DateTime.tryParse(
          value.toString(),
        ) ??
        fallback;
  }

  // ============================================================
  // DELETE EXPENSE
  // ============================================================

  static Future<void> deleteExpense(
    String expenseId,
  ) async {
    if (_expensesBox == null) {
      return;
    }

    await _expensesBox!.delete(
      expenseId,
    );
  }

  // ============================================================
  // PAYMENTS
  // ============================================================

  static Future<void> savePayment(
    PaymentData payment,
  ) async {
    if (_paymentsBox == null) {
      return;
    }

    await _paymentsBox!.put(
      payment.id,
      {
        'id': payment.id,
        'groupId': payment.groupId,
        'from': payment.from,
        'to': payment.to,
        'amount': payment.amount,
        'method': payment.method,
        'createdAt': payment.createdAt.toIso8601String(),
      },
    );
  }

  // ============================================================
  // GET PAYMENTS
  // ============================================================

  static List<PaymentData> getPayments(
    String groupId,
  ) {
    if (_paymentsBox == null) {
      return [];
    }

    final payments = <PaymentData>[];

    for (final value in _paymentsBox!.values) {
      if (value is! Map) {
        continue;
      }

      final data = Map<dynamic, dynamic>.from(
        value,
      );

      if (data['groupId']?.toString() != groupId) {
        continue;
      }

      payments.add(
        PaymentData(
          id: data['id']?.toString() ?? '',
          groupId: data['groupId']?.toString() ?? '',
          from: data['from']?.toString() ?? '',
          to: data['to']?.toString() ?? '',
          amount: _readDouble(
            data['amount'],
          ),
          method: data['method']?.toString() ?? '',
          createdAt: _readDateTime(
            data['createdAt'],
            fallback: DateTime.now(),
          ),
        ),
      );
    }

    payments.sort(
      (a, b) => b.createdAt.compareTo(
        a.createdAt,
      ),
    );

    return payments;
  }

  // ============================================================
  // DELETE PAYMENT
  // ============================================================

  static Future<void> deletePayment(
    String paymentId,
  ) async {
    if (_paymentsBox == null) {
      return;
    }

    await _paymentsBox!.delete(
      paymentId,
    );
  }

  // ============================================================
  // THEME MODE
  // ============================================================

  static String getThemeMode() {
    if (_settingsBox == null) {
      return 'system';
    }

    return _settingsBox!
            .get(
              'theme_mode',
              defaultValue: 'system',
            )
            ?.toString() ??
        'system';
  }

  static Future<void> saveThemeMode(
    String value,
  ) async {
    if (_settingsBox == null) {
      return;
    }

    await _settingsBox!.put(
      'theme_mode',
      value,
    );
  }

  // ============================================================
  // DARK MODE - COMPATIBILITY METHODS
  // ============================================================

  static bool getDarkMode() {
    final themeMode = getThemeMode();

    return themeMode == 'dark';
  }

  static Future<void> saveDarkMode(
    bool enabled,
  ) async {
    await saveThemeMode(
      enabled ? 'dark' : 'light',
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  static bool getNotificationsEnabled() {
    if (_settingsBox == null) {
      return true;
    }

    return _settingsBox!.get(
          'notifications_enabled',
          defaultValue: true,
        ) ==
        true;
  }

  static Future<void> saveNotificationsEnabled(
    bool enabled,
  ) async {
    if (_settingsBox == null) {
      return;
    }

    await _settingsBox!.put(
      'notifications_enabled',
      enabled,
    );
  }

  // ============================================================
  // EXPORT DATA AS JSON
  // Used by Settings -> Export Data
  // ============================================================

  static String exportDataAsJson() {
    final groups = <Map<String, dynamic>>[];
    final expenses = <Map<String, dynamic>>[];
    final payments = <Map<String, dynamic>>[];
    final settings = <String, dynamic>{};

    // ----------------------------------------------------------
    // GROUPS
    // ----------------------------------------------------------

    if (_groupsBox != null) {
      for (final value in _groupsBox!.values) {
        if (value is Map) {
          groups.add(
            _convertMapToStringMap(value),
          );
        }
      }
    }

    // ----------------------------------------------------------
    // EXPENSES
    // ----------------------------------------------------------

    if (_expensesBox != null) {
      for (final value in _expensesBox!.values) {
        if (value is Map) {
          expenses.add(
            _convertMapToStringMap(value),
          );
        }
      }
    }

    // ----------------------------------------------------------
    // PAYMENTS
    // ----------------------------------------------------------

    if (_paymentsBox != null) {
      for (final value in _paymentsBox!.values) {
        if (value is Map) {
          payments.add(
            _convertMapToStringMap(value),
          );
        }
      }
    }

    // ----------------------------------------------------------
    // SETTINGS
    // ----------------------------------------------------------

    if (_settingsBox != null) {
      for (final key in _settingsBox!.keys) {
        settings[key.toString()] = _settingsBox!.get(key);
      }
    }

    // ----------------------------------------------------------
    // COMPLETE EXPORT
    // ----------------------------------------------------------

    final exportData = <String, dynamic>{
      'appName': 'Campus Quick Split',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'groups': groups,
      'expenses': expenses,
      'payments': payments,
      'settings': settings,
    };

    return const JsonEncoder.withIndent(
      '  ',
    ).convert(exportData);
  }

  // ============================================================
  // CONVERT HIVE MAP TO JSON SAFE MAP
  // ============================================================

  static Map<String, dynamic> _convertMapToStringMap(
    Map<dynamic, dynamic> data,
  ) {
    final result = <String, dynamic>{};

    for (final entry in data.entries) {
      result[entry.key.toString()] = _makeJsonSafe(entry.value);
    }

    return result;
  }

  // ============================================================
  // MAKE DATA JSON SAFE
  // ============================================================

  static dynamic _makeJsonSafe(
    dynamic value,
  ) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is Map) {
      final result = <String, dynamic>{};

      for (final entry in value.entries) {
        result[entry.key.toString()] = _makeJsonSafe(entry.value);
      }

      return result;
    }

    if (value is Iterable) {
      return value
          .map(
            _makeJsonSafe,
          )
          .toList();
    }

    return value.toString();
  }

  // ============================================================
  // STORAGE SUMMARY
  // Used by Settings -> Storage
  // ============================================================

  static Map<String, int> getStorageSummary() {
    return {
      'groups': _groupsBox?.length ?? 0,
      'expenses': _expensesBox?.length ?? 0,
      'payments': _paymentsBox?.length ?? 0,
    };
  }

  // ============================================================
  // GET TOTAL STORED ITEMS
  // ============================================================

  static int getTotalStoredItems() {
    final summary = getStorageSummary();

    return summary['groups']! + summary['expenses']! + summary['payments']!;
  }

  // ============================================================
  // CLEAR ALL APP DATA
  // ============================================================

  static Future<void> clearAllData() async {
    await _groupsBox?.clear();
    await _expensesBox?.clear();
    await _paymentsBox?.clear();
  }

  // ============================================================
  // CLOSE BOXES
  // ============================================================

  static Future<void> close() async {
    await _groupsBox?.close();
    await _expensesBox?.close();
    await _paymentsBox?.close();
    await _settingsBox?.close();

    _groupsBox = null;
    _expensesBox = null;
    _paymentsBox = null;
    _settingsBox = null;
  }
}
