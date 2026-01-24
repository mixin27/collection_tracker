import 'package:collection_tracker/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection_tracker/core/observers/riverpod_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      observers: [RiverpodLogger()],
      child: const CollectionTrackerApp(),
    ),
  );
}
