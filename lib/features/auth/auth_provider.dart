import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/init_getit.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIT<AuthRepository>();
});

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isOtpSent;
  final String? phoneNumber;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isOtpSent = false,
    this.phoneNumber,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isOtpSent,
    String? phoneNumber,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

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

  Future<bool> loginWithPassword(String phone, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _repository.signInWithPassword(phone, password);
      if (success) {
        state = state.copyWith(isLoading: false, phoneNumber: phone);
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

  Future<bool> resetPasswordWithOtp({
    required String phone,
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // 1. Verify OTP first (must be correct to proceed)
      await _repository.verifyOtp(phone: phone, token: token);

      // 2. Update password in the database
      await _repository.updatePasswordInTable(phone, newPassword);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String token) async {
    if (state.phoneNumber == null) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.verifyOtp(phone: state.phoneNumber!, token: token);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    reset();
  }

  void reset() {
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
