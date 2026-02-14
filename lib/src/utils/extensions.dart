import 'package:intl/intl.dart';

/// Date/Time extensions
extension DateTimeExtension on DateTime {
  /// Check if the date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if the date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Format as "Today", "Yesterday", or date
  String get friendlyDate {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(this);
  }

  /// Format as time (e.g., "2:30 PM")
  String get friendlyTime => DateFormat('h:mm a').format(this);

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Get date key for Firestore (yyyy-MM-dd)
  String get dateKey =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

/// Number extensions for nutrition display
extension NumberExtension on num {
  /// Format with compact notation (e.g., 1.2K)
  String get compact => NumberFormat.compact().format(this);

  /// Format as fixed decimal with unit
  String withUnit(String unit, {int decimals = 0}) =>
      '${toStringAsFixed(decimals)}$unit';

  /// Format calories
  String get kcal => '${toStringAsFixed(0)} kcal';

  /// Format grams
  String get grams => '${toStringAsFixed(1)}g';
}

/// String extensions
extension StringExtension on String {
  /// Capitalize first letter
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Truncate with ellipsis
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';
}
