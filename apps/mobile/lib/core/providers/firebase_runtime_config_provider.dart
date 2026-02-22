import 'package:collection_tracker/core/firebase/firebase_runtime_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseRuntimeConfigProvider = Provider<FirebaseRuntimeConfig>(
  (ref) => FirebaseRuntimeConfig.defaults,
);
