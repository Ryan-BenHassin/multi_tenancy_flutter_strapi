class Complex {
  final int id;
  final String documentId;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;

  Complex({
    required this.id,
    required this.documentId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
  });

  factory Complex.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return Complex(
      id: json['id'] ?? 0,
      documentId: json['documentId']?.toString() ?? '',
      name: json['title']?.toString() ?? '',
      latitude: address?['latitude']?.toDouble() ?? 0.0,
      longitude: address?['longitude']?.toDouble() ?? 0.0,
      description: 'ID: ${json['documentId']}',
    );
  }
}
