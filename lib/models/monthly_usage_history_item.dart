class MonthlyUsageHistoryItem {
  final DateTime month;
  final int callsCount;
  final int messagesCount;
  final int inFlightServicesCount;
  final double dataConsumedGB;
  final int streamingServicesCount;
  final double dataRoamingGB;
  final int callsRoamingCount;
  final int messagesRoamingCount;
  final List<String> locations;

  const MonthlyUsageHistoryItem({
    required this.month,
    required this.callsCount,
    required this.messagesCount,
    required this.inFlightServicesCount,
    required this.dataConsumedGB,
    required this.streamingServicesCount,
    required this.dataRoamingGB,
    required this.callsRoamingCount,
    required this.messagesRoamingCount,
    required this.locations,
  });
}
