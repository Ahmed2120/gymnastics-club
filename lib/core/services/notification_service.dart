import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:gymnastics_club/core/utils/app_logger.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    // Local notifications are already initialized in FcmService.init(),
    // but we ensure we have the instance here for scheduling.
  }

  static Future<bool> requestPermissions() async {
    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      // Request notification permission (Android 13+)
      final bool? grantedNotification = await androidImplementation.requestNotificationsPermission();
      
      // Request exact alarm permission (Android 13+)
      final bool? grantedExactAlarm = await androidImplementation.requestExactAlarmsPermission();
      
      return (grantedNotification ?? false) && (grantedExactAlarm ?? false);
    }
    
    return true; // iOS handles its own or defaults
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Ensure the date is in the future
      if (scheduledDate.isBefore(DateTime.now())) {
        AppLogger.log('Notification scheduled date is in the past, skipping: $scheduledDate');
        return;
      }

      await _localNotifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'training_reminder_channel',
            'التنبيهات التدريبية',
            channelDescription: 'تنبيهات بمواعيد التدريب',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      AppLogger.log('Successfully scheduled notification ID $id at $scheduledDate');
    } catch (e) {
      AppLogger.log('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id: id);
    AppLogger.log('Cancelled notification ID $id');
  }

  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    AppLogger.log('Cancelled all notifications');
  }
}
