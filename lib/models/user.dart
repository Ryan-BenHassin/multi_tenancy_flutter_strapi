class User {
  final int id;
  final String email;
  final String firstname;
  final String lastname;
  final String? phone;

  User({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
    };
  }
}
