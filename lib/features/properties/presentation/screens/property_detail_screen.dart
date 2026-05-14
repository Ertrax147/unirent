import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PropertyDetailScreen extends StatelessWidget {
  final String propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Property Details $propertyId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/properties/$propertyId/reviews'),
              child: const Text('View Reviews'),
            ),
          ],
        ),
      ),
    );
  }
}
