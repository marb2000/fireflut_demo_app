class LocationFact {
  final String city;
  final String country;
  final String fact;

  LocationFact({
    required this.city,
    required this.country,
    required this.fact,
  });

  factory LocationFact.fromJson(Map<String, dynamic> json) {
    return LocationFact(
      city: json['city'] ?? 'Unknown',
      country: json['country'] ?? 'Unknown',
      fact: json['fact'] ?? 'No fact available',
    );
  }
}
