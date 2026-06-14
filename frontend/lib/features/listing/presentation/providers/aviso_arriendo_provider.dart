import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/aviso_arriendo_repository.dart';
import '../../domain/entities/aviso_arriendo_entity.dart';

final avisoArriendoRepositoryProvider = Provider<AvisoArriendoRepository>((ref) {
  return AvisoArriendoRepository();
});

final avisosProvider = FutureProvider<List<AvisoArriendoEntity>>((ref) async {
  final repository = ref.read(avisoArriendoRepositoryProvider);
  return repository.getAllAvisos();
});

final avisoDetailProvider = FutureProvider.family<AvisoArriendoEntity, String>((ref, id) async {
  final repository = ref.read(avisoArriendoRepositoryProvider);
  return repository.getAvisoById(id);
});
