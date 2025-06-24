class DataLimit {
  final String? stringValue;
  final double? numberValue;

  DataLimit.string(this.stringValue) : numberValue = null;
  DataLimit.number(this.numberValue) : stringValue = null;
  DataLimit.from(dynamic value)
      : stringValue = value is String ? value : null,
        numberValue = value is double ? value : null;

  @override
  String toString() {
    if (stringValue != null) {
      return stringValue!;
    } else if (numberValue != null) {
      return numberValue!.toString();
    }
    return '';
  }
}

class Plan {
  final String name;
  final double monthlyPrice;
  final DataLimit dataLimit;
  final String talkText;

  const Plan({
    required this.name,
    required this.monthlyPrice,
    required this.dataLimit,
    required this.talkText,
  });
}
