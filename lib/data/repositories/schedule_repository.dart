import '../dummy_data.dart';
import '../models/models/schedule_model.dart';

class ScheduleRepository {
  Future<List<ScheduleModel>> getSchedule(String groupId) async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final schedule = dummyScheduleList
          .where((e) => e['groupId'] == groupId)
          .map<ScheduleModel>((e) => ScheduleModel.fromJson(e))
          .toList();

      return schedule;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
