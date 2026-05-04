import 'package:supabase_flutter/supabase_flutter.dart';

class AppErrorHandler {
  static String handle(Object error) {
    // 1. Supabase Auth Errors
    if (error is AuthException) {
      switch (error.code) {
        case 'invalid_credentials':
          return 'رقم الهاتف أو كلمة المرور غير صحيحة';
        case 'user_not_found':
          return 'المستخدم غير موجود';
        case 'email_not_confirmed':
          return 'يرجى تأكيد بريدك الإلكتروني أولاً';
        case 'invalid_grant':
          return 'بيانات الاعتماد غير صالحة';
        case 'network_error':
          return 'فشل الاتصال بالشبكة، يرجى المحاولة مرة أخرى';
        case 'too_many_requests':
          return 'عدد محاولات كثير جداً، يرجى المحاولة لاحقاً';
        default:
          return _translateMessage(error.message);
      }
    }

    // 2. Database (Postgrest) Errors
    if (error is PostgrestException) {
      switch (error.code) {
        case '23503': // foreign_key_violation
          return 'لا يمكن إتمام العملية لوجود بيانات مرتبطة';
        case '23505': // unique_violation
          return 'هذه البيانات موجودة مسبقاً';
        case '42P01': // undefined_table
          return 'خطأ في النظام: الجدول غير موجود';
        case 'PGRST116': // JSON object requested, multiple (or no) rows returned
          return 'لم يتم العثور على البيانات المطلوبة';
        default:
          return _translateMessage(error.message);
      }
    }

    // 3. General Network / Client Errors
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('failed to fetch') ||
        errorString.contains('clientexception') ||
        errorString.contains('xmlhttprequest')) {
      return 'فشل الاتصال بالخادم، يرجى التحقق من اتصالك بالإنترنت';
    }

    if (errorString.contains('timeout')) {
      return 'انتهت مهلة الطلب، يرجى المحاولة مرة أخرى';
    }

    // Handle string exceptions (common in our repository)
    if (error is String) {
      return error;
    }

    // Handle Exception objects with message
    if (error is Exception) {
      final msg = error.toString();
      if (msg.startsWith('Exception: ')) {
        return msg.substring(11);
      }
      return msg;
    }

    return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
  }

  // Helper to translate common Supabase messages if they aren't caught by codes
  static String _translateMessage(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials')) return 'بيانات الدخول غير صحيحة';
    if (msg.contains('user already exists')) return 'المستخدم موجود مسبقاً';
    if (msg.contains('unexpected end of json input')) return 'خطأ في معالجة البيانات من الخادم';
    
    // Return original message if it doesn't look like a technical path/leak
    if (message.length < 50 && !message.contains('/') && !message.contains('\\')) {
      return message;
    }
    
    return 'حدث خطأ في النظام، يرجى المحاولة لاحقاً';
  }
}
