import 'package:intl/intl.dart';

import '../common_dependencies.dart';
import '../models/billing_info.dart';

class BalanceSummaryCard extends StatelessWidget {
  final BillingInfo billingInfo;
  final VoidCallback? onTap;
  final List<BoxDecoration>? decorations;
  final TextStyle? currentBalanceTextStyle;

  const BalanceSummaryCard({
    super.key,
    required this.billingInfo,
    this.onTap,
    this.decorations,
    this.currentBalanceTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AppCard(
          decorations: decorations ??
              [
                BoxDecoration(
                    gradient: LinearGradient(
                  colors: [$styles.colors.primary, $styles.colors.background.withAlpha(0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                ))
              ],
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Balance', style: currentBalanceTextStyle ?? TextStyle(color: $styles.colors.textSecondary)),
              SizedBox(height: $styles.insets.xs),
              Flex(
                direction: constraints.maxWidth < 360 ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: constraints.maxWidth < 360 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Text('\$${billingInfo.currentBalance.toStringAsFixed(2)}', style: textTheme.headlineMedium),
                  Row(
                    spacing: $styles.insets.xxs,
                    children: [
                      const Icon(Icons.calendar_month),
                      Text(
                          'Due in ${billingInfo.dueDate.difference(DateTime.now()).inDays} days (${DateFormat('MMM dd').format(billingInfo.dueDate)})'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: $styles.insets.lg + 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(billingInfo.autoPayEnabled ? 'AutoPay enabled' : 'AutoPay disabled', style: textTheme.bodySmall),
                  if (onTap != null) const Icon(Icons.chevron_right),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
