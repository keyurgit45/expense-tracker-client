import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat).format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.displayDateTimeFormat).format(dateTime);
  }

  static String formatDateForApi(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  static String formatDateTimeForApi(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  static DateTime? parseDate(String dateStr) {
    try {
      return DateFormat(AppConstants.dateFormat).parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  static DateTime? parseDateTime(String dateTimeStr) {
    try {
      return DateFormat(AppConstants.dateTimeFormat).parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}