import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/init_getit.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/services/fcm_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIT<AuthRepository>();
});

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isOtpSent;
  final bool isOtpVerified;
  final String? phoneNumber;
  final String? email;
  final String? otp;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isOtpSent = false,
    this.isOtpVerified = false,
    this.phoneNumber,
    this.email,
    this.otp,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isOtpSent,
    bool? isOtpVerified,
    String? phoneNumber,
    String? email,
    String? otp,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      otp: otp ?? this.otp,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  // ─── Phone OTP (kept for any existing usage) ─────────────────────────────

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.signInWithOtp(phone);
      state = state.copyWith(
        isLoading: false,
        isOtpSent: true,
        phoneNumber: phone,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ─── Phone + Password login ───────────────────────────────────────────────

  Future<bool> loginWithPassword(String phone, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _repository.signInWithPassword(phone, password);
      if (success) {
        state = state.copyWith(isLoading: false, phoneNumber: phone);
        FcmService.updateTokenForParent(phone);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'رقم الهاتف أو كلمة المرور غير صحيحة',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ─── Email OTP for forgot password ───────────────────────────────────────

  Future<void> sendEmailOtp(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.sendEmailOtp(email);
      state = state.copyWith(
        isLoading: false,
        isOtpSent: true,
        email: email,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.verifyEmailOtp(email: email, token: token);
      state = state.copyWith(
        isLoading: false,
        isOtpVerified: true,
        otp: token,
        email: email,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> resetPasswordAfterVerification({
    required String newPassword,
  }) async {
    final email = state.email;
    if (email == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.updatePasswordByEmail(email, newPassword);
      state = state.copyWith(
        isLoading: false,
        isOtpVerified: false,
        otp: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ─── Existing phone OTP reset (kept for compatibility) ───────────────────

  Future<bool> resetPasswordWithOtp({
    required String phone,
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.verifyOtp(phone: phone, token: token);
      await _repository.updatePasswordInTable(phone, newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
