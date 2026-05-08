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
      appBar: AppBar(title: const Text('Calificar Arrendador')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              '¿Qué te pareció el trato del arrendador?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
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
              decoration: const InputDecoration(
                labelText: 'Comentario (opcional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _rating == 0
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calificación enviada (MOCK)')),
                      );
                      Navigator.pop(context);
                    },
              child: const Text('Enviar Calificación'),
            ),
          ],
        ),
      ),
    );
  }
}
