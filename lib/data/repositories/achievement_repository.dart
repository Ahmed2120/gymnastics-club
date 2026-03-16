import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/init_getit.dart';
import '../../core/services/supabase_service.dart';
import '../models/models/achievement_model.dart';

class AchievementRepository {
  final SupabaseClient _client = getIT<SupabaseService>().client;

  Future<List<AchievementModel>> getAchievements(
    int childId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _client.rpc(
        'api_get_achievements',
        params: {'p_child_id': childId},
      );

      if (response == null) return [];

      final all = (response as List)
          .map<AchievementModel>((e) => AchievementModel.fromJson(e))
          .toList();

      // Client-side pagination (API returns all; we slice by page)
      final startIndex = (page - 1) * limit;
      if (startIndex >= all.length) return [];
      return all.skip(startIndex).take(limit).toList();
    } catch (e) {
      print('Error getting achievements: $e');
      rethrow;
    }
  }
}
