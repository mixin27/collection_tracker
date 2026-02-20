import 'package:collection_tracker/core/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemPriceHistoryProvider =
    StreamProvider.family<List<(DateTime, double)>, String>((ref, itemId) {
      final repository = ref.watch(itemRepositoryProvider);
      return repository.watchPriceHistory(itemId);
    });
