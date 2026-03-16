import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/init_getit.dart';
import '../../core/services/supabase_service.dart';
import '../models/models/schedule_model.dart';

class ScheduleRepository {
  final SupabaseClient _client = getIT<SupabaseService>().client;

  Future<List<ScheduleModel>> getSchedule(String groupId) async {
    try {
      final response = await _client.rpc(
        'api_get_schedule',
        params: {'p_group_id': groupId},
      );

      return (response as List)
          .map<ScheduleModel>((e) => ScheduleModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error getting schedule: $e');
      rethrow;
    }
  }
}
