import 'package:fireflut_demo_app/models/data_usage.dart';
import 'package:fireflut_demo_app/models/billing_info.dart';
import 'package:fireflut_demo_app/models/monthly_usage_history_item.dart';
import 'package:fireflut_demo_app/models/plan.dart';

class UserAccount {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  Plan currentPlan;
  final BillingInfo billingInfo;
  DataUsage dataUsage;
  final List<MonthlyUsageHistoryItem> monthlyUsageHistory;

  String get name => '$firstName $lastName';

  double? get dataLeftGB {
    final numberValue = currentPlan.dataLimit.numberValue;
    return numberValue != null ? numberValue - dataUsage.totalDataUsedGB : null;
  }

  UserAccount({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.currentPlan,
    required this.billingInfo,
    required this.dataUsage,
    required this.monthlyUsageHistory,
  });
}
