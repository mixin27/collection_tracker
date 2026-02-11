import 'package:collection_tracker/core/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagsWithUsageProvider = StreamProvider<List<(String, int)>>((ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.watchTagsWithUsage();
});

final renameTagProvider =
    FutureProvider.family<void, ({String oldName, String newName})>((
      ref,
      args,
    ) async {
      final repository = ref.read(itemRepositoryProvider);
      final result = await repository.renameTag(
        oldName: args.oldName,
        newName: args.newName,
      );
      result.fold((exception) => throw exception, (_) => null);
    });

final mergeTagsProvider =
    FutureProvider.family<void, ({String sourceName, String targetName})>((
      ref,
      args,
    ) async {
      final repository = ref.read(itemRepositoryProvider);
      final result = await repository.mergeTags(
        sourceName: args.sourceName,
        targetName: args.targetName,
      );
      result.fold((exception) => throw exception, (_) => null);
    });

final deleteTagProvider = FutureProvider.family<void, String>((
  ref,
  tagName,
) async {
  final repository = ref.read(itemRepositoryProvider);
  final result = await repository.deleteTag(tagName);
  result.fold((exception) => throw exception, (_) => null);
});
