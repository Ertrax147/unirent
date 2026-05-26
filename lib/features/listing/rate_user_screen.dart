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
  final _commentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calificar Arrendador', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Qué te pareció el trato de Juan Pérez?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tu opinión ayuda a otros estudiantes a encontrar un buen lugar.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 40,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.orange,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _commentCtrl,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu experiencia aquí (opcional)',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _rating == 0 ? 0 : 4,
                ),
                onPressed: _rating == 0
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Calificación enviada con éxito')),
                        );
                        Navigator.pop(context);
                      },
                child: const Text('Enviar Calificación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
