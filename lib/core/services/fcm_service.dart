import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gymnastics_club/core/services/init_getit.dart';
import 'package:gymnastics_club/core/services/supabase_service.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

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
      print('Error updating FCM token: $e');
    }
  }

  static Future<void> _saveTokenToDb(String phone, String token) async {
    try {
      final client = getIT<SupabaseService>().client;
      await client
          .from('parents')
          .update({'fcm_token': token})
          .eq('phone', phone);
      print('Successfully saved FCM token for parent $phone');
    } catch (e) {
      print('Error saving FCM to DB: $e');
    }
  }
}
