class DataUsage {
  final double totalDataUsedGB;
  final double maxUsage;
  final DateTime maxUsageDate;
  final double minUsage;
  final DateTime minUsageDate;
  final double callsDurationMinutes;
  final int messagesSent;

  const DataUsage({
    required this.totalDataUsedGB,
    required this.maxUsage,
    required this.maxUsageDate,
    required this.minUsage,
    required this.minUsageDate,
    required this.callsDurationMinutes,
    required this.messagesSent,
  });
}
