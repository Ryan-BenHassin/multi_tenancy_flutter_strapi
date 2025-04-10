class User {
  final int id;
  final String email;
  final String firstname;
  final String lastname;
  final String? phone;
  final String roleType;
  final Map<String, dynamic>? doctor;
  final Map<String, dynamic>? patient;

  User({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    this.phone,
    required this.roleType,
    this.doctor,
    this.patient,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      phone: json['phone'],
      roleType: json['roleType'] ?? 'PATIENT',
      doctor: json['doctor'],
      patient: json['patient'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'roleType': roleType,
      'doctor': doctor,
      'patient': patient,
    };
  }
}
