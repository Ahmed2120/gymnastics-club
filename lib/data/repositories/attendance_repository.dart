import '../dummy_data.dart';
import '../models/models/attendance_model.dart';

class AttendanceRepository {
  Future<List<AttendanceModel>> getAttendance(
    int childId, {
    int page = 1,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final startIndex = (page - 1) * limit;
      final attendance = dummyAttendanceList
          .where((e) => e['childId'] == childId)
          .skip(startIndex)
          .take(limit)
          .map<AttendanceModel>((e) => AttendanceModel.fromJson(e))
          .toList();

      return attendance;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
