import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublishPropertyScreen extends StatelessWidget {
  const PublishPropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish Property'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inbox),
            onPressed: () => context.push('/rentals/incoming'),
          )
        ],
      ),
      body: const Center(
        child: Text('Publish Property Form Here'),
      ),
    );
  }
}
