import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateUserScreen extends StatefulWidget {
  final String userId;

  const RateUserScreen({super.key, required this.userId});

  @override
  State<RateUserScreen> createState() => _RateUserScreenState();
}

class _RateUserScreenState extends State<RateUserScreen> {
  double _rating = 0;
  double _hoveredRating = 0;
  final _commentCtrl = TextEditingController();

  String get _ratingText {
    if (_rating >= 4.5) return 'Muy bueno';
    if (_rating >= 3.5) return 'Bueno';
    if (_rating >= 2.5) return 'Regular';
    if (_rating >= 1.5) return 'Malo';
    if (_rating > 0) return 'Muy malo';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Calificar usuario', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // User Info
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline, size: 40, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Text(
              'María González',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Arrendador',
                style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Main Rating
            const Text(
              '¿Cómo fue tu experiencia?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hoveredRating = starIndex.toDouble()),
                  onExit: (_) => setState(() => _hoveredRating = 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _rating = starIndex.toDouble()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(
                        starIndex <= (_hoveredRating > 0 ? _hoveredRating : _rating)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.orange,
                        size: 48,
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              Text(
                _ratingText,
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Sub Ratings Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSubRatingRow('Comunicación', 5.0),
                  const SizedBox(height: 12),
                  _buildSubRatingRow('Limpieza', 4.0),
                  const SizedBox(height: 12),
                  _buildSubRatingRow('Precisión del aviso', 4.0),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Comment Field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Comentario ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                    TextSpan(text: '(Opcional)', style: TextStyle(color: Colors.grey)),
                  ]
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              decoration: InputDecoration(
                hintText: 'Escribe un comentario sobre tu experiencia...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                ),
              ),
              maxLines: 4,
            ),
            
            const SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _rating == 0
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calificación enviada con éxito')),
                        );
                        Navigator.pop(context);
                      },
                child: const Text('Enviar calificación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Warning Note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow.shade200),
              ),
              child: Text(
                'Las calificaciones no pueden modificarse una vez enviadas.',
                style: TextStyle(color: Colors.yellow.shade800, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSubRatingRow(String title, double initialRating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade700)),
        RatingBarIndicator(
          rating: initialRating,
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.orange,
          ),
          itemCount: 5,
          itemSize: 18.0,
          unratedColor: Colors.grey.shade300,
        ),
      ],
    );
  }
}
