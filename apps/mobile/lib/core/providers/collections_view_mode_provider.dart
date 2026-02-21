import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storage/storage.dart';

part 'collections_view_mode_provider.g.dart';

enum CollectionsViewMode { list, grid }

@riverpod
class CollectionsViewModeNotifier extends _$CollectionsViewModeNotifier {
  static const _prefKey = 'collections_view_mode';
  late final PrefsStorageService _prefs;

  @override
  CollectionsViewMode build() {
    _prefs = PrefsStorageService.instance;
    final index =
        _prefs.readSync<int>(_prefKey) ?? CollectionsViewMode.list.index;
    if (index < 0 || index >= CollectionsViewMode.values.length) {
      return CollectionsViewMode.list;
    }
    return CollectionsViewMode.values[index];
  }

  Future<void> toggle() async {
    final nextMode = state == CollectionsViewMode.list
        ? CollectionsViewMode.grid
        : CollectionsViewMode.list;
    await _prefs.save<int>(_prefKey, nextMode.index);
    state = nextMode;
  }

  Future<void> setMode(CollectionsViewMode mode) async {
    await _prefs.save<int>(_prefKey, mode.index);
    state = mode;
  }
}
