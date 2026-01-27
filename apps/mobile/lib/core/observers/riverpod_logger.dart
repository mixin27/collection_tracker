import 'package:app_logger/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A basic logger, which logs any state changes.
final class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    Logger.debug('''
{
  "provider": "${context.provider}",
  "newValue": "$newValue",
  "mutation": "${context.mutation}"
}''');
  }
}
