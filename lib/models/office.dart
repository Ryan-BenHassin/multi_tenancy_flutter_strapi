class Office {
  final String id;
  final String documentId;
  final String name;
  final String? description;
  final double longitude;
  final double latitude;

  Office({
    required this.id,
    required this.documentId,
    required this.name,
    this.description,
    required this.longitude,
    required this.latitude,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id'].toString(),
      documentId: json['documentId'] ?? '',
      name: json['title'] ?? '',
      description: json['description'],
      longitude: json['longitude']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
    );
  }
}

