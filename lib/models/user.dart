class User {
  int? id;
  String? name;
  String? image;
  String? email;
  String? token;
  String? personId;
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
      id: json['user']['id'],
      name: json['user']['name'],
      image: json['user']['image'],
      email: json['user']['email'],
      token: json['token'],
      personId: json['user']
          ['person_id'], // Asignar el valor de person_id al campo personId
    );
  }
}
