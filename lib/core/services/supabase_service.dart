import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

class SupabaseService {
  static Future<void> init() async {
    if (!SupabaseConstants.isConfigured) {
      throw Exception(
        'Supabase configuration is missing. \n'
        'Ensure you are running with: --dart-define-from-file=.env.json\n'
        'For Shorebird releases, ensure the flag is after the -- separator.',
      );
    }
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );
  }

  SupabaseClient get client => Supabase.instance.client;
}
