import 'package:collection_tracker/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

export 'package:collection_tracker/l10n/gen/app_localizations.dart';

/// Extension to access the [AppLocalizations] instance in a [BuildContext].
extension AppLocalizationsX on BuildContext {
  /// Returns the [AppLocalizations] instance for the current [BuildContext].
  AppLocalizations get l10n => AppLocalizations.of(this);
}
