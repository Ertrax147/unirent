import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  final String propertyId;
  const ReviewsScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reviews for $propertyId')),
      body: const Center(child: Text('List of Reviews')),
    );
  }
}
