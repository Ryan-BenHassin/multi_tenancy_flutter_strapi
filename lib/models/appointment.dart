class Booking {
  final String id;
  final String documentId;
  final DateTime date;
  final String statusBooking;
  final Map<String, dynamic> office;
  final Map<String, dynamic> patient;

  Booking({
    required this.id,
    required this.documentId,
    required this.date,
    required this.statusBooking,
    required this.office,
    required this.patient,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      documentId: json['documentId'],
      date: DateTime.parse(json['date']),
      statusBooking: json['status_booking'] ?? 'PENDING',
      office: json['office'] ?? {},
      patient: json['patient'] ?? {},
    );
  }
}
