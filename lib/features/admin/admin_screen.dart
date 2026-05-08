import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/auth_provider.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Usuarios Registrados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Rol')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: const [
                  DataRow(cells: [
                     DataCell(Text('estudiante@ufromail.cl')),
                     DataCell(Text('Estudiante')),
                     DataCell(Icon(Icons.block, color: Colors.red)),
                  ]),
                  DataRow(cells: [
                     DataCell(Text('arrendador@ufromail.cl')),
                     DataCell(Text('Arrendador')),
                     DataCell(Icon(Icons.block, color: Colors.red)),
                  ]),
                ],
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Audit Log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text('Acción ${index + 1}'),
                  subtitle: Text('2024-05-${10 + index} 14:00 - Resultado OK'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
