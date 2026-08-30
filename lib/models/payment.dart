class PaymentData {
  final String id;
  final String groupId;
  final String from;
  final String to;
  final double amount;
  final String method;
  final DateTime createdAt;

  const PaymentData({
    required this.id,
    required this.groupId,
    required this.from,
    required this.to,
    required this.amount,
    required this.method,
    required this.createdAt,
  });
}

