import 'package:envied/envied.dart';

part 'app_env.g.dart';

@Envied(path: '.env')
abstract class AppEnv {
  @EnviedField(varName: 'GOOGLE_BOOKS_API_KEY', obfuscate: true)
  static final String googleBooksApiKey = _AppEnv.googleBooksApiKey;
  @EnviedField(varName: 'IGDB_CLIENT_ID', obfuscate: true)
  static final String igdbClientId = _AppEnv.igdbClientId;
  @EnviedField(varName: 'IGDB_CLIENT_SECRET', obfuscate: true)
  static final String igdbClientSecret = _AppEnv.igdbClientSecret;
  @EnviedField(varName: 'TMDB_API_KEY', obfuscate: true)
  static final String tmdbApiKey = _AppEnv.tmdbApiKey;
  @EnviedField(varName: 'TMDB_READ_ACCESS_TOKEN', obfuscate: true)
  static final String tmdbReadAccessToken = _AppEnv.tmdbReadAccessToken;
}
