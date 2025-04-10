class Office {
  final int id;
  final String documentId;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;

  Office({
    required this.id,
    required this.documentId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id'] ?? 0,
      documentId: json['documentId']?.toString() ?? '',
      name: json['title']?.toString() ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      description: json['description'],
    );
  }
}
