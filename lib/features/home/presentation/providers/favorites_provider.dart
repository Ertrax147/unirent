import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/favorite_repository.dart';
import 'package:unirent/features/auth/presentation/providers/auth_provider.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository();
});

class FavoritesNotifier extends AsyncNotifier<List<int>> {
  @override
  Future<List<int>> build() async {
    // Escuchar el estado de autenticación para que si el usuario cambia, 
    // la lista de favoritos se vuelva a consultar en la base de datos automáticamente.
    final authState = ref.watch(authStateProvider);
    
    // Si no hay usuario, retornamos lista vacía sin llamar a la API
    if (authState.user == null) return [];

    final repository = ref.watch(favoriteRepositoryProvider);
    return await repository.getFavorites();
  }

  Future<void> toggleFavorite(int listingId) async {
    final repository = ref.read(favoriteRepositoryProvider);
    final previousState = state.value ?? [];
    final isCurrentlyFavorite = previousState.contains(listingId);

    // Optimistic update
    if (isCurrentlyFavorite) {
      state = AsyncData(previousState.where((i) => i != listingId).toList());
    } else {
      state = AsyncData([...previousState, listingId]);
    }

    try {
      if (isCurrentlyFavorite) {
        await repository.removeFavorite(listingId);
      } else {
        await repository.addFavorite(listingId);
      }
    } catch (e) {
      // Revert on error
      state = AsyncData(previousState);
      throw Exception('Error toggling favorite: $e');
    }
  }

  bool isFavorite(int listingId) {
    return state.value?.contains(listingId) ?? false;
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<int>>(() {
  return FavoritesNotifier();
});
