import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/app_logger.dart';
import '../../core/services/init_getit.dart';
import '../../core/services/supabase_service.dart';
import '../models/models/permission_model.dart';

class PermissionRepository {
  final SupabaseClient _client = getIT<SupabaseService>().client;

  Future<List<PermissionModel>> getRequests({
    required String childName,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _client.rpc('api_get_permissions', params: {
        'p_name': childName,
        'p_status': status ?? '',
        'p_page': page,
        'p_limit': limit,
      });

      return (response as List)
          .map<PermissionModel>((e) => PermissionModel.fromJson(e))
          .toList();
    } catch (e) {
      AppLogger.log('Error getting permission requests: $e');
      rethrow;
    }
  }

  Future<void> submitRequest(PermissionModel request) async {
    try {
      await _client.from('permissions').insert(request.toJson());
    } catch (e) {
      AppLogger.log('Error submitting permission request: $e');
      rethrow;
    }
  }
}
