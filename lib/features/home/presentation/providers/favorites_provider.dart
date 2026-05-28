import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesNotifier extends Notifier<List<int>> {
  @override
  List<int> build() => [];

  void toggleFavorite(int index) {
    if (state.contains(index)) {
      state = state.where((i) => i != index).toList();
    } else {
      state = [...state, index];
    }
  }

  bool isFavorite(int index) {
    return state.contains(index);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<int>>(() {
  return FavoritesNotifier();
});
