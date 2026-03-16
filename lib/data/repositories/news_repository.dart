import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/init_getit.dart';
import '../../core/services/supabase_service.dart';
import '../models/models/news_model.dart';

class NewsRepositories {
  final SupabaseClient _client = getIT<SupabaseService>().client;

  Future<List<NewsModel>> getNews({
    required int page,
    int limit = 10,
    List<String>? groupIds,
    String? phone,
  }) async {
    try {
      // All filtering (expiry, group, ordering, pagination) is done server-side
      // inside the api_get_news Supabase RPC function.
      final response = await _client.rpc(
        'api_get_news',
        params: {
          'p_page': page,
          'p_group_ids': groupIds, // null = global news only
          'p_phone': phone,
        },
      );

      if (response == null) return [];

      return (response as List)
          .map<NewsModel>((e) => NewsModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error getting news: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> toggleLike(int newsId, String phone) async {
    try {
      final response = await _client.rpc(
        'api_toggle_news_like',
        params: {
          'p_news_id': newsId,
          'p_phone': phone,
        },
      );
      print(response);
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }
}
