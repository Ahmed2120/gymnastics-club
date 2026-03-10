import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/init_getit.dart';
import '../../core/services/supabase_service.dart';
import '../models/models/permission_model.dart';

class PermissionRepository {
  final SupabaseClient _client = getIT<SupabaseService>().client;

  Future<List<PermissionModel>> getRequests({
    required String childName,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final response = await _client
          .from('permissions')
          .select()
          .eq('employeeName', childName)
          .order('id', ascending: false)
          .range(from, to);

      return (response as List)
          .map<PermissionModel>((e) => PermissionModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error getting permission requests: $e');
      rethrow;
    }
  }

  Future<void> submitRequest(PermissionModel request) async {
    try {
      await _client.from('permissions').insert(request.toJson());
    } catch (e) {
      print('Error submitting permission request: $e');
      rethrow;
    }
  }
}
