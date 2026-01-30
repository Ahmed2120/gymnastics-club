// import '../../../data/models/models/schedule_model.dart';
//
// extension ScheduleFormValidationExtension on Map<int, ScheduleModel> {
//   bool get isComplete {
//     return values.every((schedule) =>
//     schedule.day.isNotEmpty &&
//         schedule.startTime != null &&
//         schedule.startTime!.isNotEmpty &&
//         schedule.endTime != null &&
//         schedule.endTime!.isNotEmpty
//     );
//   }
//
//   int get completedCount {
//     return values.where((schedule) =>
//     schedule.day.isNotEmpty &&
//         schedule.startTime != null &&
//         schedule.startTime!.isNotEmpty &&
//         schedule.endTime != null &&
//         schedule.endTime!.isNotEmpty
//     ).length;
//   }
// }