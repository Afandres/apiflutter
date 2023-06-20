class User {
  int? id;
  String? name;
  String? image;
  String? email;
  String? token;
  final String? personId;

  User({
    this.id,
    this.name,
    this.image,
    this.email,
    this.token,
    this.personId,
  });

  // Función para convertir datos JSON a un modelo de usuario
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['nickname'],
      image: null,
      email: json['email'],
      token: json['token'],
      personId: json['person_id'].toString(),
    );
  }
}
