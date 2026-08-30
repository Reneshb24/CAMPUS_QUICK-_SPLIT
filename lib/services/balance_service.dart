import '../models/expense.dart';
import '../models/payment.dart';

class SettlementData {
  final String from;
  final String to;
  final double amount;

  const SettlementData({
    required this.from,
    required this.to,
    required this.amount,
  });
}

class BalanceService {
  static const double _tolerance = 0.01;

  // ============================================================
  // CALCULATE BALANCES
  // ============================================================

  static Map<String, double> calculateBalances({
    required List<String> members,
    required List<ExpenseData> expenses,
    List<PaymentData> payments = const [],
  }) {
    final balances = <String, double>{
      for (final member in members) member: 0.0,
    };

    // ==========================================================
    // EXPENSES
    // ==========================================================

    for (final expense in expenses) {
      if (expense.amount <= 0) {
        continue;
      }

      // ========================================================
      // MULTIPLE PAYERS
      // ========================================================

      final payerSplits = expense.effectivePayerSplits;

      for (final entry in payerSplits.entries) {
        final payer = entry.key;
        final paidAmount = entry.value;

        if (paidAmount <= 0) {
          continue;
        }

        balances.putIfAbsent(
          payer,
          () => 0.0,
        );

        balances[payer] = balances[payer]! + paidAmount;
      }

      // ========================================================
      // PARTICIPANTS OWING THEIR SHARE
      // ========================================================

      for (final participant in expense.participants) {
        balances.putIfAbsent(
          participant,
          () => 0.0,
        );

        final share = expense.amountForMember(
          participant,
        );

        balances[participant] = balances[participant]! - share;
      }
    }

    // ==========================================================
    // SETTLEMENT PAYMENTS
    // ==========================================================

    for (final payment in payments) {
      if (payment.amount <= 0) {
        continue;
      }

      balances.putIfAbsent(
        payment.from,
        () => 0.0,
      );

      balances.putIfAbsent(
        payment.to,
        () => 0.0,
      );

      // Debtor pays creditor.

      balances[payment.from] = balances[payment.from]! + payment.amount;

      balances[payment.to] = balances[payment.to]! - payment.amount;
    }

    // ==========================================================
    // CLEAN FLOATING POINT VALUES
    // ==========================================================

    balances.updateAll(
      (member, balance) {
        if (balance.abs() < _tolerance) {
          return 0.0;
        }

        return _roundCurrency(
          balance,
        );
      },
    );

    return balances;
  }

  // ============================================================
  // CALCULATE MINIMUM SETTLEMENTS
  // ============================================================

  static List<SettlementData> calculateSettlements(
    Map<String, double> balances,
  ) {
    final debtors = <_BalancePerson>[];

    final creditors = <_BalancePerson>[];

    // ==========================================================
    // SEPARATE MEMBERS
    // ==========================================================

    for (final entry in balances.entries) {
      final member = entry.key;
      final balance = entry.value;

      if (balance < -_tolerance) {
        debtors.add(
          _BalancePerson(
            name: member,
            amount: -balance,
          ),
        );
      } else if (balance > _tolerance) {
        creditors.add(
          _BalancePerson(
            name: member,
            amount: balance,
          ),
        );
      }
    }

    // ==========================================================
    // LARGEST BALANCES FIRST
    // ==========================================================

    debtors.sort(
      (a, b) => b.amount.compareTo(a.amount),
    );

    creditors.sort(
      (a, b) => b.amount.compareTo(a.amount),
    );

    final settlements = <SettlementData>[];

    var debtorIndex = 0;
    var creditorIndex = 0;

    // ==========================================================
    // MINIMUM TRANSACTION ALGORITHM
    // ==========================================================

    while (debtorIndex < debtors.length && creditorIndex < creditors.length) {
      final debtor = debtors[debtorIndex];

      final creditor = creditors[creditorIndex];

      final amount =
          debtor.amount < creditor.amount ? debtor.amount : creditor.amount;

      final roundedAmount = _roundCurrency(amount);

      if (roundedAmount > _tolerance) {
        settlements.add(
          SettlementData(
            from: debtor.name,
            to: creditor.name,
            amount: roundedAmount,
          ),
        );
      }

      debtor.amount -= amount;
      creditor.amount -= amount;

      if (debtor.amount.abs() <= _tolerance) {
        debtorIndex++;
      }

      if (creditor.amount.abs() <= _tolerance) {
        creditorIndex++;
      }
    }

    return settlements;
  }

  // ============================================================
  // ROUND CURRENCY
  // ============================================================

  static double _roundCurrency(
    double value,
  ) {
    return double.parse(
      value.toStringAsFixed(2),
    );
  }
}

class _BalancePerson {
  final String name;
  double amount;

  _BalancePerson({
    required this.name,
    required this.amount,
  });
}
