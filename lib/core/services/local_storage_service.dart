import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Reminder enabled state
  static const String _reminderEnabledKey = 'next_training_reminder_enabled';
  
  // Reminder offset in minutes (1 hour = 60, 30 minutes = 30)
  static const String _reminderOffsetKey = 'next_training_reminder_offset';

  // User persistence
  static const String _userPhoneKey = 'user_phone';

  static Future<void> setReminderEnabled(bool enabled) async {
    await _prefs.setBool(_reminderEnabledKey, enabled);
  }

  static bool isReminderEnabled() {
    return _prefs.getBool(_reminderEnabledKey) ?? false;
  }

  static Future<void> setReminderOffset(int minutes) async {
    await _prefs.setInt(_reminderOffsetKey, minutes);
  }

  static int getReminderOffset() {
    return _prefs.getInt(_reminderOffsetKey) ?? 60; // Default 1 hour
  }

  // User Persistence
  static Future<void> setUserPhone(String? phone) async {
    if (phone == null) {
      await _prefs.remove(_userPhoneKey);
    } else {
      await _prefs.setString(_userPhoneKey, phone);
    }
  }

  static String? getUserPhone() {
    return _prefs.getString(_userPhoneKey);
  }

  // Showcase / onboarding tutorial
  static const String _showcaseSeenKey = 'showcase_seen_v1';

  static Future<void> setShowcaseSeen() async {
    await _prefs.setBool(_showcaseSeenKey, true);
  }

  static bool isShowcaseSeen() {
    return _prefs.getBool(_showcaseSeenKey) ?? false;
  }
}
