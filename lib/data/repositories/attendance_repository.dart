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
      final from = (page - 1) * limit;
      final to = from + limit - 1;

      // Note: The system analysis suggests attendance table has child_id.
      // We might need to join with other tables if the model requires 'name' or 'group'.
      // For history, we'll fetch from the 'attendance' table.
      final response = await _client
          .from('attendance')
          .select()
          .eq('childId', childId)
          .order('date', ascending: false)
          .range(from, to);
print(response);
      return (response as List).map((e) {
        // Map DB fields to Model fields if they differ
        // DB might have 'status' instead of 'didAttend'
        return AttendanceModel.fromJson({
          ...e,
          'childId': e['childId'],
          'didAttend':
              e['didAttend'], // Assuming status is 'Present'/'Absent'
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
