import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/app_logger.dart';
import '../../core/services/init_getit.dart';
import '../../core/services/supabase_service.dart';

class AuthRepository {
  final SupabaseClient _client = getIT<SupabaseService>().client;

  // ─── Phone login (unchanged) ─────────────────────────────────────────────

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
      final bool isValid = await _client.rpc('verify_parent_password', params: {
        'p_phone': phone,
        'p_password': password,
      });

      return isValid;
    } catch (e) {
      AppLogger.log('Error signing in with password: $e');
      rethrow;
    }
  }

  Future<void> updatePasswordInTable(String phone, String newPassword) async {
    try {
      final bool success = await _client.rpc('api_update_parent_password', params: {
        'p_phone': phone,
        'p_password': newPassword,
      });

      if (!success) {
        throw Exception('فشل تحديث كلمة المرور');
      }
    } catch (e) {
      AppLogger.log('Error updating password: $e');
      rethrow;
    }
  }

  // ─── Email OTP for forgot password ──────────────────────────────────────

  Future<void> sendEmailOtp(String email) async {
    try {
      final response = await _client.functions.invoke(
        'send-reset-otp',
        body: {'email': email},
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'حدث خطأ ما';
        throw Exception(error);
      }
    } on FunctionException catch (e) {
      final msg = (e.details is Map ? e.details['error']?.toString() : null) ??
          e.reasonPhrase ??
          'حدث خطأ ما';
      throw Exception(msg);
    } catch (e) {
      AppLogger.log('Error sending email OTP: $e');
      rethrow;
    }
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    try {
      final isValid = await _client.rpc('api_verify_otp', params: {
        'p_email': email,
        'p_otp': token,
      });

      if (isValid != true) {
        throw 'كود التحقق غير صحيح أو انتهت صلاحيته';
      }
    } catch (e) {
      AppLogger.log('Error verifying email OTP: $e');
      rethrow;
    }
  }

  /// Finds the parent by their email address and updates the password.
  Future<void> updatePasswordByEmail(String email, String newPassword) async {
    try {
      final parent = await _client
          .from('parents')
          .select('phone')
          .eq('email', email)
          .maybeSingle();

      if (parent == null) {
        throw Exception('لم يتم العثور على حساب بهذا البريد الإلكتروني');
      }

      final String phone = parent['phone'];
      
      final bool success = await _client.rpc('api_update_parent_password', params: {
        'p_phone': phone,
        'p_password': newPassword,
      });

      if (!success) {
        throw Exception('فشل تحديث كلمة المرور');
      }
    } catch (e) {
      AppLogger.log('Error updating password by email: $e');
      rethrow;
    }
  }

  // ─── Common ──────────────────────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;

  Future<bool> checkParentExists(String phone) async {
    try {
      final parent = await _client
          .from('parents')
          .select('phone')
          .eq('phone', phone)
          .maybeSingle();
      return parent != null;
    } catch (e) {
      AppLogger.log('Error checking parent existence: $e');
      return false;
    }
  }

  Future<bool> verifyMembershipNumber(String phone, String membershipNumber) async {
    try {
      final response = await _client.rpc('api_verify_membership', params: {
        'p_phone': phone,
        'p_membership_number': membershipNumber,
      });
      return response as bool;
    } catch (e) {
      AppLogger.log('Error verifying membership number: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
