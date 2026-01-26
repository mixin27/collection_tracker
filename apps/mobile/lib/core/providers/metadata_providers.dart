import 'package:common_env/common_env.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:metadata_api/metadata_api.dart';

part 'metadata_providers.g.dart';

@riverpod
Dio metadataDio(Ref ref) {
  return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ),
    )
    ..interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // Use your logging package here
          // logger.debug(obj.toString());
          debugPrint(obj.toString());
        },
      ),
    ]);
}

// ============================================================
// API Keys Providers
// These should be loaded from secure storage or environment
// ============================================================

@riverpod
String googleBooksApiKey(Ref ref) {
  return AppEnv.googleBooksApiKey;
}

@riverpod
Future<String> igdbClientId(Ref ref) async {
  return AppEnv.igdbClientId;
}

@riverpod
Future<String> igdbAccessToken(Ref ref) async {
  // todo(mixin27): Load from secure storage or fetch fresh token
  // You might want to cache this and refresh when expired
  final clientId = await ref.watch(igdbClientIdProvider.future);
  final clientSecret = AppEnv.igdbClientSecret;

  final result = await IGDBAuth.getAccessToken(
    clientId: clientId,
    clientSecret: clientSecret,
    dio: ref.watch(metadataDioProvider),
  );

  return result.fold(
    (exception) => throw Exception('Failed to get IGDB access token'),
    (token) => token,
  );
}

@riverpod
String tmdbApiKey(Ref ref) {
  return AppEnv.tmdbReadAccessToken;
}

// ============================================================
// Client Providers
// ============================================================

@riverpod
GoogleBooksClient googleBooksClient(Ref ref) {
  final apiKey = ref.watch(googleBooksApiKeyProvider);
  final dio = ref.watch(metadataDioProvider);

  return GoogleBooksClient(apiKey: apiKey.isEmpty ? null : apiKey, dio: dio);
}

@riverpod
Future<IGDBClient> igdbClient(Ref ref) async {
  final clientId = await ref.watch(igdbClientIdProvider.future);
  final accessToken = await ref.watch(igdbAccessTokenProvider.future);
  final dio = ref.watch(metadataDioProvider);

  return IGDBClient(clientId: clientId, accessToken: accessToken, dio: dio);
}

@riverpod
TMDBClient tmdbClient(Ref ref) {
  final apiKey = ref.watch(tmdbApiKeyProvider);
  final dio = ref.watch(metadataDioProvider);

  return TMDBClient(apiKey: apiKey, dio: dio);
}

// ============================================================
// Unified Metadata Service Provider
// ============================================================

@riverpod
class MetadataService extends _$MetadataService {
  @override
  FutureOr<void> build() async {
    // Initialize service
  }

  GoogleBooksClient get booksClient => ref.read(googleBooksClientProvider);

  Future<IGDBClient> get gamesClient => ref.read(igdbClientProvider.future);

  TMDBClient get moviesClient => ref.read(tmdbClientProvider);
}

@riverpod
Future<UnifiedMetadataService> unifiedMetadataService(Ref ref) async {
  final booksClient = ref.watch(googleBooksClientProvider);
  final gamesClient = await ref.watch(igdbClientProvider.future);
  final moviesClient = ref.watch(tmdbClientProvider);

  return UnifiedMetadataService(
    booksClient: booksClient,
    gamesClient: gamesClient,
    moviesClient: moviesClient,
  );
}

@riverpod
Future<SmartMetadataMatcher> smartMetadataMatcher(Ref ref) async {
  final service = await ref.watch(unifiedMetadataServiceProvider.future);
  return SmartMetadataMatcher(service);
}
