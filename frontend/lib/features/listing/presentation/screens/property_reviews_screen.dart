import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unirent/features/listing/presentation/providers/reviews_provider.dart';
import 'package:unirent/features/auth/presentation/providers/user_public_provider.dart';

class PropertyReviewsScreen extends ConsumerWidget {
  final String targetUserId;

  const PropertyReviewsScreen({super.key, required this.targetUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(userReviewsProvider(targetUserId));
    final statsAsync = ref.watch(userReviewStatsProvider(targetUserId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Reseñas', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return const Center(
              child: Text(
                'Este usuario aún no tiene reseñas.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Calcular distribución de estrellas
          List<int> starCounts = [0, 0, 0, 0, 0, 0]; // index 0 no se usa
          for (var r in reviews) {
            if (r.stars >= 1 && r.stars <= 5) {
              starCounts[r.stars]++;
            }
          }

          return Column(
            children: [
              // Header summary
              statsAsync.when(
                data: (stats) => Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(stats.average.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                          Row(
                            children: List.generate(5, (index) {
                              if (index < stats.average.floor()) {
                                return const Icon(Icons.star, color: Colors.orange, size: 20);
                              } else if (index < stats.average.ceil() && stats.average - stats.average.floor() >= 0.5) {
                                return const Icon(Icons.star_half, color: Colors.orange, size: 20);
                              } else {
                                return const Icon(Icons.star_border, color: Colors.orange, size: 20);
                              }
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text('${stats.count} reseñas', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          children: [
                            _buildRatingBar(5, starCounts[5] / stats.count),
                            _buildRatingBar(4, starCounts[4] / stats.count),
                            _buildRatingBar(3, starCounts[3] / stats.count),
                            _buildRatingBar(2, starCounts[2] / stats.count),
                            _buildRatingBar(1, starCounts[1] / stats.count),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const Divider(height: 1),
              
              // Reviews List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) => const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return _ReviewItem(review: review);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
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
                value: percent.isNaN ? 0 : percent,
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

class _ReviewItem extends ConsumerWidget {
  final ReviewEntity review;

  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Buscar perfil público del autor de la reseña
    final authorAsync = ref.watch(userPublicProvider(review.authorUserId));
    
    final dateStr = review.timestamp != null 
        ? _formatTimeAgo(review.timestamp!) 
        : 'Recientemente';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            authorAsync.when(
              data: (author) => CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: author['photoUrl'] != null && author['photoUrl'].toString().isNotEmpty
                    ? NetworkImage(author['photoUrl'])
                    : null,
                child: author['photoUrl'] == null || author['photoUrl'].toString().isEmpty
                    ? const Icon(Icons.person, color: Colors.blue, size: 20)
                    : null,
              ),
              loading: () => const CircleAvatar(radius: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, __) => const CircleAvatar(radius: 20, child: Icon(Icons.person)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  authorAsync.when(
                    data: (author) => Text(
                      author['displayName'] ?? 'Usuario',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    loading: () => const Text('Cargando...'),
                    error: (_, __) => const Text('Usuario'),
                  ),
                  Row(
                    children: [
                      Text(dateStr, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          review.isStudent ? 'Estudiante' : 'Arrendador',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (starIndex) => Icon(
            starIndex < review.stars ? Icons.star : Icons.star_border,
            color: Colors.orange,
            size: 16,
          )),
        ),
        if (review.comment.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ],
      ],
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return 'Hace ${diff.inDays ~/ 365} años';
    if (diff.inDays > 30) return 'Hace ${diff.inDays ~/ 30} meses';
    if (diff.inDays > 0) return 'Hace ${diff.inDays} días';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} horas';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} min';
    return 'Hace un momento';
  }
}
