import 'package:flutter/material.dart';

import '../../models/payment.dart';
import '../../services/storage_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final List<PaymentData> payments;

  const PaymentHistoryScreen({
    super.key,
    required this.payments,
  });

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late List<PaymentData> _payments;

  @override
  void initState() {
    super.initState();

    _payments = List.from(widget.payments);
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // PAYMENT ICON
  // ============================================================

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'UPI':
        return Icons.account_balance_wallet_rounded;

      case 'Cash':
        return Icons.payments_rounded;

      case 'Bank Transfer':
        return Icons.account_balance_rounded;

      default:
        return Icons.payments_outlined;
    }
  }

  // ============================================================
  // DELETE PAYMENT
  // ============================================================

  Future<void> _deletePayment(
    PaymentData payment,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete payment?',
          ),
          content: Text(
            'Delete the payment of '
            '₹${payment.amount.toStringAsFixed(0)} '
            'from ${payment.from} to ${payment.to}?',
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

    await StorageService.deletePayment(
      payment.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _payments.removeWhere(
        (item) => item.id == payment.id,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Payment deleted',
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment History',
        ),
      ),
      body: _payments.isEmpty
          ? const _EmptyPaymentHistory()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Dismissible(
                    key: ValueKey(payment.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      await _deletePayment(payment);

                      return false;
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(
                        right: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                      ),
                    ),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              child: Icon(
                                _getPaymentIcon(
                                  payment.method,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${payment.from} paid '
                                    '${payment.to}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${payment.method} • '
                                    '${_formatDate(payment.createdAt)}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '₹${payment.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
// EMPTY PAYMENT HISTORY
// ============================================================

class _EmptyPaymentHistory extends StatelessWidget {
  const _EmptyPaymentHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(height: 18),
            const Text(
              'No payments yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Settlements you record will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
