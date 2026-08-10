import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _fullFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  static final _shortFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dayMonth = DateFormat('dd MMM', 'id_ID');
  static final _dayName = DateFormat('EEEE', 'id_ID');
  static final _timeFormat = DateFormat('HH:mm', 'id_ID');

  static String full(DateTime date) => _fullFormat.format(date);
  static String short(DateTime date) => _shortFormat.format(date);
  static String dayMonth(DateTime date) => _dayMonth.format(date);
  static String dayName(DateTime date) => _dayName.format(date);
  static String time(DateTime date) => _timeFormat.format(date);

  static String dateRange(DateTime start, DateTime end) {
    if (start.month == end.month && start.year == end.year) {
      return '${start.day} - ${_fullFormat.format(end)}';
    }
    return '${_shortFormat.format(start)} - ${_shortFormat.format(end)}';
  }

  static int nightsBetween(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return _shortFormat.format(date);
  }
}
