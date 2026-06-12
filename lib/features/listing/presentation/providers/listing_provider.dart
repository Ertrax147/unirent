import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/listing_repository.dart';
import '../../domain/entities/listing_entity.dart';

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository();
});

final listingsProvider = FutureProvider<List<ListingEntity>>((ref) async {
  final repository = ref.watch(listingRepositoryProvider);
  return repository.getAllListings();
});
