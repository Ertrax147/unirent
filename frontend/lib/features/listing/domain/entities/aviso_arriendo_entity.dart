class AvisoArriendoEntity {
  final String? id;
  final String arrendadorId;
  final String titulo;
  final String descripcion;
  final double precio;
  final String ciudad;
  final String direccion;
  final Map<String, double> ubicacion;
  final bool disponible;
  final int cuposDisponibles;

  AvisoArriendoEntity({
    this.id,
    required this.arrendadorId,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.ciudad,
    required this.direccion,
    required this.ubicacion,
    this.disponible = true,
    this.cuposDisponibles = 1,
  });

  factory AvisoArriendoEntity.fromJson(Map<String, dynamic> json) {
    return AvisoArriendoEntity(
      id: json['id'],
      arrendadorId: json['arrendador_id'] ?? json['arrendadorId'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      ciudad: json['ciudad'] ?? '',
      direccion: json['direccion'] ?? '',
      ubicacion: json['ubicacion'] != null 
          ? Map<String, double>.from(json['ubicacion'])
          : {'lat': -38.7359, 'lng': -72.5904},
      disponible: json['disponible'] ?? true,
      cuposDisponibles: json['cupos_disponibles'] ?? json['cuposDisponibles'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'arrendadorId': arrendadorId,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'ciudad': ciudad,
      'direccion': direccion,
      'ubicacion': ubicacion,
      'disponible': disponible,
      'cuposDisponibles': cuposDisponibles,
    };
  }
}
