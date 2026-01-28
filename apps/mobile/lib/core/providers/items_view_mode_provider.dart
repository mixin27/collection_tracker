import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storage/storage.dart';

part 'items_view_mode_provider.g.dart';

enum ItemsViewMode { list, grid }

@riverpod
class ItemsViewModeNotifier extends _$ItemsViewModeNotifier {
  late final PrefsStorageService _prefs;

  @override
  ItemsViewMode build() {
    _prefs = PrefsStorageService.instance;
    final index =
        _prefs.readSync<int>('items_view_mode') ?? ItemsViewMode.list.index;
    return ItemsViewMode.values[index];
  }

  Future<void> toggle() async {
    final nextMode = state == ItemsViewMode.list
        ? ItemsViewMode.grid
        : ItemsViewMode.list;
    await _prefs.save<int>('items_view_mode', nextMode.index);
    state = nextMode;
  }
}
