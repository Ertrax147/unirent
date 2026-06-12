class ListingEntity {
  final int id;
  final String title;
  final String price;
  final String location;
  final String type;
  final String rating;
  final String imageUrl;

  ListingEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.type,
    required this.rating,
    required this.imageUrl,
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
    );
  }
}
