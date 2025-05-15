import 'package:intl/intl.dart';

class DateFormatterService {
  static String toApiFormat(DateTime dateTime) {
    return DateFormat('yyyyMMdd').format(dateTime);
  }

  static String toDisplayFormat(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static DateTime? fromApiFormat(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat('yyyyMMdd').parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
