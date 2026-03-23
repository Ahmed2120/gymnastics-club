import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gymnastics_club/core/utils/app_logger.dart';
import 'package:gymnastics_club/core/services/init_getit.dart';
import 'package:gymnastics_club/core/services/supabase_service.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static Future<void> init() async {
    // Initializing the local notifications plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
    );

    // Create the high importance channel (Android only)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: android?.smallIcon,
            ),
          ),
        );
      }
    });
  }

  static Future<void> updateTokenForParent(String phone) async {
    try {
      await _messaging.requestPermission();
      final token = await _messaging.getToken();
      
      if (token != null) {
        await _saveTokenToDb(phone, token);
      }

      _messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToDb(phone, newToken);
      });
    } catch (e) {
      AppLogger.log('Error updating FCM token: $e');
    }
  }

  static Future<void> _saveTokenToDb(String phone, String token) async {
    try {
      final client = getIT<SupabaseService>().client;
      await client
          .from('parents')
          .update({'fcm_token': token})
          .eq('phone', phone);
      AppLogger.log('Successfully saved FCM token for parent $phone');
    } catch (e) {
      AppLogger.log('Error saving FCM to DB: $e');
    }
  }
}
