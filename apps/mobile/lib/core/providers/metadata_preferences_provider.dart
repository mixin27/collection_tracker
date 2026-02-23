import 'package:collection_tracker/core/firebase/firebase_runtime_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';

import 'firebase_runtime_config_provider.dart';

class MetadataPreferencesState {
  const MetadataPreferencesState({
    required this.preferenceEnabled,
    required this.autoFetchBarcodeEnabled,
    required this.fillOnlyEmptyFields,
    required this.runtimeFeatureEnabled,
  });

  final bool preferenceEnabled;
  final bool autoFetchBarcodeEnabled;
  final bool fillOnlyEmptyFields;
  final bool runtimeFeatureEnabled;

  bool get isEnabled => runtimeFeatureEnabled && preferenceEnabled;
  bool get canAutoFetchFromBarcode => isEnabled && autoFetchBarcodeEnabled;

  MetadataPreferencesState copyWith({
    bool? preferenceEnabled,
    bool? autoFetchBarcodeEnabled,
    bool? fillOnlyEmptyFields,
    bool? runtimeFeatureEnabled,
  }) {
    return MetadataPreferencesState(
      preferenceEnabled: preferenceEnabled ?? this.preferenceEnabled,
      autoFetchBarcodeEnabled:
          autoFetchBarcodeEnabled ?? this.autoFetchBarcodeEnabled,
      fillOnlyEmptyFields: fillOnlyEmptyFields ?? this.fillOnlyEmptyFields,
      runtimeFeatureEnabled:
          runtimeFeatureEnabled ?? this.runtimeFeatureEnabled,
    );
  }
}

final metadataPreferencesProvider =
    NotifierProvider<MetadataPreferencesController, MetadataPreferencesState>(
      MetadataPreferencesController.new,
    );

class MetadataPreferencesController extends Notifier<MetadataPreferencesState> {
  static const _enabledKey = 'metadata_feature_enabled';
  static const _autoFetchBarcodeKey = 'metadata_auto_fetch_barcode';
  static const _fillEmptyOnlyKey = 'metadata_fill_empty_only';

  late final PrefsStorageService _prefs;

  @override
  MetadataPreferencesState build() {
    _prefs = PrefsStorageService.instance;

    ref.listen<FirebaseRuntimeConfig>(firebaseRuntimeConfigProvider, (
      previous,
      next,
    ) {
      if (previous?.metadataFeatureEnabled == next.metadataFeatureEnabled) {
        return;
      }
      state = state.copyWith(
        runtimeFeatureEnabled: next.metadataFeatureEnabled,
      );
    });

    return MetadataPreferencesState(
      preferenceEnabled: _prefs.readSync<bool>(_enabledKey) ?? true,
      autoFetchBarcodeEnabled:
          _prefs.readSync<bool>(_autoFetchBarcodeKey) ?? true,
      fillOnlyEmptyFields: _prefs.readSync<bool>(_fillEmptyOnlyKey) ?? true,
      runtimeFeatureEnabled: ref
          .read(firebaseRuntimeConfigProvider)
          .metadataFeatureEnabled,
    );
  }

  Future<void> setPreferenceEnabled(bool enabled) async {
    await _prefs.save<bool>(_enabledKey, enabled);
    state = state.copyWith(preferenceEnabled: enabled);
  }

  Future<void> setAutoFetchBarcodeEnabled(bool enabled) async {
    await _prefs.save<bool>(_autoFetchBarcodeKey, enabled);
    state = state.copyWith(autoFetchBarcodeEnabled: enabled);
  }

  Future<void> setFillOnlyEmptyFields(bool enabled) async {
    await _prefs.save<bool>(_fillEmptyOnlyKey, enabled);
    state = state.copyWith(fillOnlyEmptyFields: enabled);
  }
}
