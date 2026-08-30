class ExpenseData {
  final String id;
  final String title;
  final double amount;
  final String category;

  /// Legacy primary payer.
  ///
  /// This remains for backward compatibility with older saved expenses.
  final String paidBy;

  /// Multiple people can contribute to paying one expense.
  ///
  /// Example:
  ///
  /// {
  ///   'Renesh': 600,
  ///   'John': 400,
  /// }
  final Map<String, double> payerSplits;

  final List<String> participants;

  /// Actual date when the expense happened.
  final DateTime expenseDate;

  /// Date when this record was created.
  final DateTime createdAt;

  /// equal, custom, percentage, ratio
  final String splitType;

  /// Fixed custom amount for each participant.
  final Map<String, double> customSplits;

  /// Percentage for each participant.
  final Map<String, double> percentageSplits;

  /// Ratio for each participant.
  final Map<String, double> ratioSplits;

  ExpenseData({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.participants,
    required this.expenseDate,
    required this.createdAt,
    this.splitType = 'equal',
    Map<String, double>? payerSplits,
    Map<String, double>? customSplits,
    Map<String, double>? percentageSplits,
    Map<String, double>? ratioSplits,
  })  : payerSplits = payerSplits ?? {},
        customSplits = customSplits ?? {},
        percentageSplits = percentageSplits ?? {},
        ratioSplits = ratioSplits ?? {};

  // ============================================================
  // EFFECTIVE PAYER SPLITS
  // ============================================================

  Map<String, double> get effectivePayerSplits {
    if (payerSplits.isNotEmpty) {
      return Map<String, double>.from(payerSplits);
    }

    if (paidBy.isNotEmpty && amount > 0) {
      return {
        paidBy: amount,
      };
    }

    return {};
  }

  // ============================================================
  // TOTAL PAID
  // ============================================================

  double get totalPaid {
    return effectivePayerSplits.values.fold(
      0.0,
      (total, value) => total + value,
    );
  }

  // ============================================================
  // AMOUNT PAID BY MEMBER
  // ============================================================

  double paidAmountForMember(String member) {
    return effectivePayerSplits[member] ?? 0.0;
  }

  // ============================================================
  // EQUAL SPLIT AMOUNT
  // ============================================================

  double get splitAmount {
    if (participants.isEmpty) {
      return 0.0;
    }

    return amount / participants.length;
  }

  // ============================================================
  // TOTAL RATIO
  // ============================================================

  double get totalRatio {
    return participants.fold(
      0.0,
      (total, member) {
        return total + (ratioSplits[member] ?? 0.0);
      },
    );
  }

  // ============================================================
  // MEMBER SHARE
  // ============================================================

  double amountForMember(String member) {
    if (!participants.contains(member)) {
      return 0.0;
    }

    switch (splitType) {
      case 'custom':
        return customSplits[member] ?? 0.0;

      case 'percentage':
        final percentage = percentageSplits[member] ?? 0.0;

        return amount * percentage / 100;

      case 'ratio':
        final ratio = ratioSplits[member] ?? 0.0;

        final ratioTotal = totalRatio;

        if (ratioTotal <= 0) {
          return 0.0;
        }

        return amount * ratio / ratioTotal;

      case 'equal':
      default:
        return splitAmount;
    }
  }

  // ============================================================
  // TOTAL PARTICIPANT SHARE
  // ============================================================

  double get totalParticipantShares {
    return participants.fold(
      0.0,
      (total, member) {
        return total + amountForMember(member);
      },
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  ExpenseData copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? paidBy,
    Map<String, double>? payerSplits,
    List<String>? participants,
    DateTime? expenseDate,
    DateTime? createdAt,
    String? splitType,
    Map<String, double>? customSplits,
    Map<String, double>? percentageSplits,
    Map<String, double>? ratioSplits,
  }) {
    return ExpenseData(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paidBy: paidBy ?? this.paidBy,
      payerSplits: payerSplits ??
          Map<String, double>.from(
            this.payerSplits,
          ),
      participants: participants ??
          List<String>.from(
            this.participants,
          ),
      expenseDate: expenseDate ?? this.expenseDate,
      createdAt: createdAt ?? this.createdAt,
      splitType: splitType ?? this.splitType,
      customSplits: customSplits ??
          Map<String, double>.from(
            this.customSplits,
          ),
      percentageSplits: percentageSplits ??
          Map<String, double>.from(
            this.percentageSplits,
          ),
      ratioSplits: ratioSplits ??
          Map<String, double>.from(
            this.ratioSplits,
          ),
    );
  }
}
