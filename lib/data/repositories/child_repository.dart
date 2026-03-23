import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/app_logger.dart';
import '../../core/services/init_getit.dart';
import '../../core/services/supabase_service.dart';
import '../models/models/child_model.dart';

class ChildRepository {
  final SupabaseClient _client = getIT<SupabaseService>().client;

  Future<List<ChildModel>> getChildren({String? phone}) async {
    try {
      final effectivePhone = phone ?? _client.auth.currentUser?.phone;
      if (effectivePhone == null) return [];

      final response = await _client.rpc(
        'api_get_children_by_parent',
        params: {'p_phone': effectivePhone},
      );

      return (response as List)
          .map<ChildModel>((e) => ChildModel.fromJson(e))
          .toList();
    } catch (e) {
      AppLogger.log('Error getting children: $e');
      rethrow;
    }
  }

  Future<ChildModel> getChildDetails(int id) async {
    try {
      final response = await _client
          .from('children')
          .select()
          .eq('id', id)
          .single();
      return ChildModel.fromJson(response);
    } catch (e) {
      AppLogger.log('Error getting child details: $e');
      rethrow;
    }
  }
}
