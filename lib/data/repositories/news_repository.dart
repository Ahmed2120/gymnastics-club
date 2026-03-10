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
  }) async {
    try {
      print('groups::::: $groupIds');
      final from = (page - 1) * limit;
      final to = from + limit - 1;

      // Filter: global news (group_id is null) OR news in specific groups
      var query = _client.from('news').select();

      if (groupIds != null && groupIds.isNotEmpty) {
        // News where group_id is null OR in groupIds
        // Supabase filter for OR can be tricky with nulls.
        // We'll use the RPC if available, or a filter string.
        query = query.or(
          'group_id.is.null,group_id.in.(${groupIds.join(",")})',
        );
      } else {
        query = query.filter('group_id', 'is', null);
      }

      final response = await query
          .order('id', ascending: false)
          .range(from, to);

      print('.......................');
      print(groupIds);

      return (response as List)
          .map<NewsModel>((e) => NewsModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error getting news: $e');
      rethrow;
    }
  }
}
