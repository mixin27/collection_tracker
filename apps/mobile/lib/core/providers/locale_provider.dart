import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:storage/storage.dart';

part 'locale_provider.g.dart';

enum AppLanguage {
  system,
  english,
  spanish,
  indonesian,
  japanese,
  korean,
  chineseSimplified,
  burmese,
}

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
    AppLanguage.system => 'system',
    AppLanguage.english => 'en',
    AppLanguage.spanish => 'es',
    AppLanguage.indonesian => 'id',
    AppLanguage.japanese => 'ja',
    AppLanguage.korean => 'ko',
    AppLanguage.chineseSimplified => 'zh',
    AppLanguage.burmese => 'my',
  };

  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.english => const Locale('en'),
    AppLanguage.spanish => const Locale('es'),
    AppLanguage.indonesian => const Locale('id'),
    AppLanguage.japanese => const Locale('ja'),
    AppLanguage.korean => const Locale('ko'),
    AppLanguage.chineseSimplified => const Locale('zh'),
    AppLanguage.burmese => const Locale('my'),
  };

  static AppLanguage fromCode(String? code) {
    for (final language in AppLanguage.values) {
      if (language.code == code) return language;
    }
    return AppLanguage.system;
  }
}

@riverpod
class LocaleSettingsNotifier extends _$LocaleSettingsNotifier {
  static const _prefKey = 'app_language';
  late final PrefsStorageService _prefs;

  @override
  AppLanguage build() {
    _prefs = PrefsStorageService.instance;
    final savedCode = _prefs.readSync<String>(_prefKey);
    return AppLanguageX.fromCode(savedCode);
  }

  Future<void> setLanguage(AppLanguage language) async {
    await _prefs.save<String>(_prefKey, language.code);
    state = language;
  }
}
