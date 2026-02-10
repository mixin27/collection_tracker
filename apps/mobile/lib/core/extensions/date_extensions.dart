import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String formatMediumDate() {
    return DateFormat.yMMMd().format(this);
  }

  String formatFullDate() {
    return DateFormat.yMMMMEEEEd().format(this);
  }
}
