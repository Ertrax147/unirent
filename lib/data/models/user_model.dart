class UserModel {
  final String uid;
  final String email;
  final String nombreCompleto;
  final String rol; // 'estudiante', 'arrendador', 'admin'
  final bool isSuspended;
  final double rating;

  UserModel({
    required this.uid,
    required this.email,
    required this.nombreCompleto,
    required this.rol,
    this.isSuspended = false,
    this.rating = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nombreCompleto': nombreCompleto,
      'rol': rol,
      'isSuspended': isSuspended,
      'rating': rating,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      email: map['email'] ?? '',
      nombreCompleto: map['nombreCompleto'] ?? '',
      rol: map['rol'] ?? 'estudiante',
      isSuspended: map['isSuspended'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }
}
