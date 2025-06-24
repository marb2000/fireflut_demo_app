import 'package:fireflut_demo_app/models/bill_history_item.dart';

class BillingInfo {
  final double currentBalance;
  final DateTime dueDate;
  final bool autoPayEnabled;
  final String paymentMethod;
  final List<BillHistoryItem> billHistory;

  const BillingInfo({
    required this.currentBalance,
    required this.dueDate,
    required this.autoPayEnabled,
    required this.paymentMethod,
    required this.billHistory,
  });
}
