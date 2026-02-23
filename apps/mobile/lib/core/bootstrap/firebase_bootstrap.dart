import 'package:app_logger/app_logger.dart';
import 'package:collection_tracker/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

abstract final class FirebaseBootstrap {
  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      Logger.debug('Firebase already initialized.');
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Logger.info('Firebase initialized.');
    } on UnsupportedError catch (error, stackTrace) {
      Logger.warning('Firebase initialization skipped: $error');
      Logger.error('Firebase initialization unsupported.', error, stackTrace);
    } on FirebaseException catch (error, stackTrace) {
      Logger.error(
        'Firebase initialization failed (${error.code}).',
        error,
        stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      Logger.error(
        'Unexpected Firebase initialization failure.',
        error,
        stackTrace,
      );
      rethrow;
    }
  }
}
