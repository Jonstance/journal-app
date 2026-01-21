import 'package:intl/intl.dart';

class DateFormatters {
  static final day = DateFormat('EEE, MMM d');
  static final full = DateFormat('EEEE, MMMM d, y');
  static final time = DateFormat('h:mm a');
  static final monthYear = DateFormat('MMMM y');
  static final short = DateFormat('MMM d');
}
