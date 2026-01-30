import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../routing/app_router.dart';

class DateConverter {
  static TimeOfDay? parseTimeToTimeOfDay(String timeString) {
    try {
      final timeParts = timeString.split(':');
      final hourStr = timeParts[0].trim();
      final minuteAndPeriod = timeParts[1].trim().split(' ');
      final minuteStr = minuteAndPeriod[0].trim();
      final period = minuteAndPeriod.length > 1
          ? minuteAndPeriod[1].trim()
          : '';

      int hour = int.parse(hourStr);
      int minute = int.parse(minuteStr);

      if ((period == 'م' || period == 'PM') && hour != 12) hour += 12;
      if ((period == 'ص' || period == 'AM') && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  static bool isTimeAfter(String sessionTime, DateTime reference) {
    final tod = parseTimeToTimeOfDay(sessionTime);
    if (tod == null) return false;

    if (tod.hour > reference.hour) return true;
    if (tod.hour == reference.hour && tod.minute > reference.minute)
      return true;

    return false;
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }

  static String formatToTime(TimeOfDay time, {String? languageCode}) {
    final isArabic = languageCode == 'ar';

    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');

    final period = time.period == DayPeriod.am
        ? (isArabic ? 'ص' : 'AM')
        : (isArabic ? 'م' : 'PM');

    return '$hour:$minute $period';
  }

  static TimeOfDay formatToTimeOfDay(String timeString) {
    final parts = timeString.trim().split(' ');
    final timeParts = parts[0].split(':');

    int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);
    final String period = parts[1].toUpperCase();

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  static String dateToTimeOnly(DateTime dateTime) {
    return DateFormat(_timeFormatter()).format(dateTime);
  }

  static String dateToDateAndTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  static String dateToDateAndTimeAm(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd ${_timeFormatter()}').format(dateTime);
  }

  static String dateToDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String dateToReadableDate(String? dateTime) {
    if (dateTime != null) {
      final date = DateTime.parse(dateTime);
      return DateFormat(
        'dd MMM, yyy',
        navigatorKey.currentContext?.locale.languageCode,
      ).format(date);
    }
    return '';
  }

  static String dateToReadableDayAndMonth(String? dateTime) {
    if (dateTime != null) {
      final date = DateTime.parse(dateTime);
      return DateFormat(
        'dd MMM',
        navigatorKey.currentContext?.locale.languageCode,
      ).format(date);
    }
    return '';
  }

  static String dateTimeStringToDateTime(String dateTime) {
    return DateFormat(
      'dd MMM yyyy  ${_timeFormatter()}',
    ).format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static String dateTimeStringToDateOnly(String dateTime) {
    return DateFormat(
      'dd MMM yyyy',
    ).format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static DateTime dateTimeStringToDate(String dateTime) {
    return DateTime.parse(dateTime);
  }

  static DateTime isoStringToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime);
  }

  static String isoStringToLocalString(String dateTime) {
    return DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.parse(dateTime).toLocal());
  }

  static String isoStringToReadableString(String dateTime) {
    return DateFormat(
      'dd MMMM, yyyy HH:mm a',
    ).format(DateTime.parse(dateTime).toLocal());
  }

  static String startAndEndTime(
    String dateStr,
    String startTimeStr,
    String endTimeStr,
  ) {
    // Convert date string to DateTime

    // Convert time strings to DateTime by appending to date
    DateTime date = DateTime.parse(dateStr);

    // Format day, month, and date
    String dayMonth = DateFormat('E, MMM d').format(date);

    // Convert start and end times manually
    String startTimeFormatted = formatTime(startTimeStr);
    String endTimeFormatted = formatTime(endTimeStr, includeAMPM: true);

    return "$dayMonth / $startTimeFormatted–$endTimeFormatted";
  }

  static String formatTime(String timeStr, {bool includeAMPM = false}) {
    List<String> parts = timeStr.split(
      ':',
    ); // Split "14:41:00" into ["14", "41", "00"]
    print('parts');
    print(parts);
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    String formattedHour = (hour > 12)
        ? (hour - 12).toString()
        : hour.toString();
    if (hour == 0) formattedHour = "12"; // Midnight case
    if (hour == 12) formattedHour = "12"; // Noon case

    String formattedMinute = minute.toString().padLeft(2, '0');
    String amPm = (hour >= 12) ? "PM" : "AM";

    return includeAMPM
        ? "$formattedHour:$formattedMinute $amPm"
        : "$formattedHour:$formattedMinute";
  }

  static String isoStringToDateTimeString(String dateTime) {
    return DateFormat(
      'dd MMM yyyy  ${_timeFormatter()}',
    ).format(isoStringToLocalDate(dateTime));
  }

  static String isoStringToLocalDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(isoStringToLocalDate(dateTime));
  }

  static String stringToLocalDateOnly(String dateTime) {
    return DateFormat(
      'dd MMM yyyy',
    ).format(DateFormat('yyyy-MM-dd').parse(dateTime));
  }

  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(dateTime);
  }

  static String convertTimeToTime(String time) {
    return DateFormat(_timeFormatter()).format(DateFormat('HH:mm').parse(time));
  }

  static DateTime convertStringTimeToDate(String time) {
    return DateFormat('HH:mm').parse(time);
  }

  static String convertTimeToTimeDate(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static bool isAvailable(String? start, String? end, {DateTime? time}) {
    DateTime currentTime;
    if (time != null) {
      currentTime = time;
    } else {
      currentTime = DateTime.now();
    }
    DateTime start0 = start != null
        ? DateFormat('HH:mm').parse(start)
        : DateTime(currentTime.year);
    DateTime end0 = end != null
        ? DateFormat('HH:mm').parse(end)
        : DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            23,
            59,
            59,
          );
    DateTime startTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      start0.hour,
      start0.minute,
      start0.second,
    );
    DateTime endTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      end0.hour,
      end0.minute,
      end0.second,
    );
    if (endTime.isBefore(startTime)) {
      if (currentTime.isBefore(startTime) && currentTime.isBefore(endTime)) {
        startTime = startTime.add(const Duration(days: -1));
      } else {
        endTime = endTime.add(const Duration(days: 1));
      }
    }
    return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
  }

  static String _timeFormatter() {
    return 'hh:mm a';
  }

  static String convertFromMinute(int minMinute, int maxMinute) {
    int firstValue = minMinute;
    int secondValue = maxMinute;
    String type = 'min';
    if (minMinute >= 525600) {
      firstValue = (minMinute / 525600).floor();
      secondValue = (maxMinute / 525600).floor();
      type = 'year';
    } else if (minMinute >= 43200) {
      firstValue = (minMinute / 43200).floor();
      secondValue = (maxMinute / 43200).floor();
      type = 'month';
    } else if (minMinute >= 10080) {
      firstValue = (minMinute / 10080).floor();
      secondValue = (maxMinute / 10080).floor();
      type = 'week';
    } else if (minMinute >= 1440) {
      firstValue = (minMinute / 1440).floor();
      secondValue = (maxMinute / 1440).floor();
      type = 'day';
    } else if (minMinute >= 60) {
      firstValue = (minMinute / 60).floor();
      secondValue = (maxMinute / 60).floor();
      type = 'hour';
    }
    return '$firstValue-$secondValue ${type}';
  }

  static String localDateToIsoStringAMPM(DateTime dateTime) {
    return DateFormat(
      '${_timeFormatter()} | d-MMM-yyyy ',
    ).format(dateTime.toLocal());
  }

  static bool isBeforeTime(String? dateTime) {
    if (dateTime == null) {
      return false;
    }
    DateTime scheduleTime = dateTimeStringToDate(dateTime);
    return scheduleTime.isBefore(DateTime.now());
  }

  static bool isAfterTime(String? dateTime) {
    if (dateTime == null) {
      return false;
    }
    DateTime scheduleTime = dateTimeStringToDate(dateTime);
    return scheduleTime.isAfter(DateTime.now());
  }

  static int differenceInMinute(
    String? deliveryTime,
    String? orderTime,
    int? processingTime,
    String? scheduleAt,
  ) {
    // 'min', 'hours', 'days'
    int minTime = processingTime ?? 0;
    if (deliveryTime != null &&
        deliveryTime.isNotEmpty &&
        processingTime == null) {
      try {
        List<String> timeList = deliveryTime.split('-'); // ['15', '20']
        minTime = int.parse(timeList[0]);
      } catch (_) {}
    }
    DateTime deliveryTime0 = dateTimeStringToDate(
      scheduleAt ?? orderTime!,
    ).add(Duration(minutes: minTime));
    return deliveryTime0.difference(DateTime.now()).inMinutes;
  }

  static String convertTodayYesterdayFormat(String createdAt) {
    final now = DateTime.now();
    final createdAtDate = DateTime.parse(createdAt).toLocal();

    if (createdAtDate.year == now.year &&
        createdAtDate.month == now.month &&
        createdAtDate.day == now.day) {
      return 'Today, ${DateFormat.jm().format(createdAtDate)}';
    } else if (createdAtDate.year == now.year &&
        createdAtDate.month == now.month &&
        createdAtDate.day == now.day - 1) {
      return 'Yesterday, ${DateFormat.jm().format(createdAtDate)}';
    } else {
      return DateConverter.localDateToIsoStringAMPM(createdAtDate);
    }
  }

  static String convertOnlyTodayTime(String createdAt) {
    final now = DateTime.now();
    final createdAtDate = DateTime.parse(createdAt).toLocal();

    if (createdAtDate.year == now.year &&
        createdAtDate.month == now.month &&
        createdAtDate.day == now.day) {
      return DateFormat('h:mm a').format(createdAtDate);
    } else {
      return DateConverter.localDateToIsoStringAMPM(createdAtDate);
    }
  }

  static String simpleDateTime(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('MMMM d, y').format(date);
  }

  static String formatDuration(String startTimeStr, String endTimeStr) {
    // Convert times to DateTime for easy calculation
    DateTime startTime = convertToDateTime(startTimeStr);
    DateTime endTime = convertToDateTime(endTimeStr);

    // Calculate duration in hours
    int durationHours = endTime.difference(startTime).inHours;

    // Format time in 12-hour format with AM/PM
    String formattedStartTime = formatTime(startTimeStr);
    String formattedEndTime = formatTime(endTimeStr);

    return "Duration: $durationHours hours ($formattedStartTime - $formattedEndTime)";
  }

  static DateTime convertToDateTime(String timeStr) {
    List<String> parts = timeStr.split(
      ':',
    ); // Split "12:00:00" into ["12", "00", "00"]
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  static String timeAgoSinceDate(String dateTime, {bool numericDates = true}) {
    DateTime date = DateTime.parse(dateTime).toLocal();
    final date2 = DateTime.now().toLocal();
    final difference = date2.difference(date);

    if (difference.inSeconds < 5) {
      return 'الان';
    } else if (difference.inSeconds <= 60) {
      return ' منذ ${difference.inSeconds} ثواني';
    } else if (difference.inMinutes <= 1) {
      return (numericDates) ? 'منذ دقيقة' : 'A minute ago';
    } else if (difference.inMinutes <= 60) {
      return ' منذ ${difference.inMinutes} دقائق';
    } else if (difference.inHours <= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inHours <= 60) {
      return ' منذ ${difference.inHours} ساعات';
    } else if (difference.inDays <= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inDays <= 6) {
      return ' منذ ${difference.inDays} ايام';
    } else if ((difference.inDays / 7).ceil() <= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if ((difference.inDays / 7).ceil() <= 4) {
      return ' منذ ${(difference.inDays / 7).ceil()} اسابيع';
    } else if ((difference.inDays / 30).ceil() <= 1) {
      return (numericDates) ? '1 month ago' : 'Last month';
    } else if ((difference.inDays / 30).ceil() <= 30) {
      return ' منذ ${(difference.inDays / 30).ceil()} شهور';
    } else if ((difference.inDays / 365).ceil() <= 1) {
      return (numericDates) ? '1 year ago' : 'Last year';
    }
    return ' منذ ${(difference.inDays / 365).floor()} سنين';
  }
}
