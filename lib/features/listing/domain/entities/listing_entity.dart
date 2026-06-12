class ListingEntity {
  final int id;
  final String title;
  final String price;
  final String location;
  final String type;
  final String rating;
  final String imageUrl;
  final String ownerId;
  final double? latitude;
  final double? longitude;
  final String status;

  ListingEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.type,
    required this.rating,
    required this.imageUrl,
    required this.ownerId,
    this.latitude,
    this.longitude,
    this.status = 'AVAILABLE',
  });

  factory ListingEntity.fromJson(Map<String, dynamic> json) {
    return ListingEntity(
      id: json['id'],
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      rating: json['rating'] ?? '',
      imageUrl: json['imageUrl'] ?? 'assets/images/prop_0.png',
      ownerId: json['ownerId'] ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      status: json['status'] ?? 'AVAILABLE',
    );
  }
}
