import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/init_getit.dart';
import '../../core/services/supabase_service.dart';
import '../models/models/attendance_model.dart';

class AttendanceRepository {
  final SupabaseClient _client = getIT<SupabaseService>().client;

  Future<List<AttendanceModel>> getAttendance(
    int childId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {

      // Note: The system analysis suggests attendance table has child_id.
      // We might need to join with other tables if the model requires 'name' or 'group'.
      // For history, we'll fetch from the 'attendance' table.
      // Using api_get_child_attendance RPC for server-side pagination
      final response = await _client.rpc('api_get_child_attendance', params: {
        'p_child_id': childId,
        'p_page': page,
        'p_limit': limit,
      });
      print(response);
      return (response as List).map((e) {
        // Map DB fields to Model fields if they differ
        return AttendanceModel.fromJson({
          ...e,
          'childId': e['childId'],
          'didAttend': e['didAttend'], 
        });
      }).toList();
    } catch (e) {
      print('Error getting attendance: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> subscribeToAttendance(int childId) {
    return _client
        .from('attendance')
        .stream(primaryKey: ['id'])
        .eq('childId', childId);
  }
}
