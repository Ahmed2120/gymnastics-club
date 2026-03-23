import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/app_logger.dart';
import '../../core/services/init_getit.dart';
import '../../core/services/supabase_service.dart';

class AuthRepository {
  final SupabaseClient _client = getIT<SupabaseService>().client;

  Future<void> signInWithOtp(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } catch (e) {
      AppLogger.log('Error signing in with OTP: $e');
      rethrow;
    }
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      return response;
    } catch (e) {
      AppLogger.log('Error verifying OTP: $e');
      rethrow;
    }
  }

  Future<bool> signInWithPassword(String phone, String password) async {
    try {
      final response = await _client
          .from('parents')
          .select()
          .eq('phone', phone)
          .eq('password', password)
          .maybeSingle();

      return response != null;
    } catch (e) {
      AppLogger.log('Error signing in with password: $e');
      rethrow;
    }
  }

  Future<void> updatePasswordInTable(String phone, String newPassword) async {
    try {
      await _client
          .from('parents')
          .update({'password': newPassword})
          .eq('phone', phone);
    } catch (e) {
      AppLogger.log('Error updating password: $e');
      rethrow;
    }
  }

  User? get currentUser => _client.auth.currentUser;

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
