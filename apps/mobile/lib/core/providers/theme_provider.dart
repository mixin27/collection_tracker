import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storage/storage.dart';
import 'package:ui/ui.dart';

part 'theme_provider.g.dart';

class ThemeSettings {
  final ThemeMode mode;
  final AppThemeVariant variant;
  final bool amoled;

  const ThemeSettings({
    required this.mode,
    required this.variant,
    required this.amoled,
  });

  ThemeSettings copyWith({
    ThemeMode? mode,
    AppThemeVariant? variant,
    bool? amoled,
  }) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      variant: variant ?? this.variant,
      amoled: amoled ?? this.amoled,
    );
  }
}

@riverpod
class ThemeSettingsNotifier extends _$ThemeSettingsNotifier {
  late final PrefsStorageService _prefs;

  @override
  ThemeSettings build() {
    _prefs = PrefsStorageService.instance;

    final modeIndex =
        _prefs.readSync<int>('theme_mode') ?? ThemeMode.system.index;
    final variantIndex =
        _prefs.readSync<int>('theme_variant') ?? AppThemeVariant.blue.index;
    final amoled = _prefs.readSync<bool>('theme_amoled') ?? false;

    return ThemeSettings(
      mode: ThemeMode.values[modeIndex],
      variant: AppThemeVariant.values[variantIndex],
      amoled: amoled,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.save<int>('theme_mode', mode.index);
    state = state.copyWith(mode: mode);
  }

  Future<void> setThemeVariant(AppThemeVariant variant) async {
    await _prefs.save<int>('theme_variant', variant.index);
    state = state.copyWith(variant: variant);
  }

  Future<void> setAmoled(bool amoled) async {
    await _prefs.save<bool>('theme_amoled', amoled);
    state = state.copyWith(amoled: amoled);
  }
}
