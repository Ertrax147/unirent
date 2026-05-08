class ListingModel {
  final String id;
  final String landlordId;
  final String titulo;
  final String direccion;
  final String descripcion;
  final int precioMensual;
  final String tipo; // 'habitación', 'departamento', 'pensión'
  final String sector;
  final DateTime fechaDisponibilidad;
  final List<String> imageUrls;

  ListingModel({
    required this.id,
    required this.landlordId,
    required this.titulo,
    required this.direccion,
    required this.descripcion,
    required this.precioMensual,
    required this.tipo,
    required this.sector,
    required this.fechaDisponibilidad,
    required this.imageUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'landlordId': landlordId,
      'titulo': titulo,
      'direccion': direccion,
      'descripcion': descripcion,
      'precioMensual': precioMensual,
      'tipo': tipo,
      'sector': sector,
      'fechaDisponibilidad': fechaDisponibilidad.toIso8601String(),
      'imageUrls': imageUrls,
    };
  }

  factory ListingModel.fromMap(Map<String, dynamic> map, String docId) {
    return ListingModel(
      id: docId,
      landlordId: map['landlordId'] ?? '',
      titulo: map['titulo'] ?? '',
      direccion: map['direccion'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precioMensual: map['precioMensual']?.toInt() ?? 0,
      tipo: map['tipo'] ?? 'habitación',
      sector: map['sector'] ?? '',
      fechaDisponibilidad: map['fechaDisponibilidad'] != null
          ? DateTime.parse(map['fechaDisponibilidad'])
          : DateTime.now(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }
}
