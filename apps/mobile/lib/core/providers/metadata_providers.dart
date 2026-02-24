import 'package:common_env/common_env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';

import '../metadata/metadata_lookup_service.dart';

final metadataSecureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.instance;
});

final metadataApiConfigProvider = Provider<MetadataApiConfig>((ref) {
  return MetadataApiConfig(
    googleBooksApiKey: AppEnv.googleBooksApiKey,
    igdbClientId: AppEnv.igdbClientId,
    igdbClientSecret: AppEnv.igdbClientSecret,
    tmdbReadAccessToken: AppEnv.tmdbReadAccessToken,
  );
});

final metadataLookupServiceProvider = Provider<MetadataLookupService>((ref) {
  final config = ref.watch(metadataApiConfigProvider);
  final secureStorage = ref.watch(metadataSecureStorageProvider);
  return MetadataLookupService(config: config, secureStorage: secureStorage);
});
