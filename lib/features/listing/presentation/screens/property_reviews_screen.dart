import 'package:flutter/material.dart';

class PropertyReviewsScreen extends StatelessWidget {
  final String propertyId;

  const PropertyReviewsScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockReviews = [
      {
        'user': 'María González',
        'avatar': 'https://i.pravatar.cc/150?img=5',
        'rating': 5,
        'date': 'Hace 2 semanas',
        'comment': 'Excelente lugar, muy limpio y el arrendador es súper amable. Totalmente recomendado.',
      },
      {
        'user': 'Carlos Rojas',
        'avatar': 'https://i.pravatar.cc/150?img=12',
        'rating': 4,
        'date': 'Hace 1 mes',
        'comment': 'Buen lugar por el precio. La ubicación es ideal para ir caminando a la U.',
      },
      {
        'user': 'Camila Flores',
        'avatar': 'https://i.pravatar.cc/150?img=1',
        'rating': 5,
        'date': 'Hace 2 meses',
        'comment': 'Me encantó mi estadía aquí. Muy seguro y tranquilo para estudiar.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reseñas', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header summary
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              children: [
                Column(
                  children: [
                    const Text('4.8', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                    Row(
                      children: List.generate(5, (index) => Icon(
                        index < 4 ? Icons.star : Icons.star_half,
                        color: Colors.orange,
                        size: 20,
                      )),
                    ),
                    const SizedBox(height: 4),
                    Text('12 reseñas', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar(5, 0.8),
                      _buildRatingBar(4, 0.15),
                      _buildRatingBar(3, 0.05),
                      _buildRatingBar(2, 0.0),
                      _buildRatingBar(1, 0.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Reviews List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockReviews.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final review = mockReviews[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(review['avatar']),
                          radius: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(review['user'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(review['date'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (starIndex) => Icon(
                        starIndex < review['rating'] ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 16,
                      )),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review['comment'],
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$star', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey.shade200,
                color: Colors.orange,
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
