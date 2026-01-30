import 'package:flutter_riverpod/legacy.dart';
import 'package:gymnastics_club/core/services/init_getit.dart';
import '../../../data/repositories/schedule_repository.dart';
import 'schedule_state.dart';

final scheduleRiverpod = StateNotifierProvider<ScheduleRiverpod, ScheduleState>(
  (ref) {
    return ScheduleRiverpod();
  },
);

class ScheduleRiverpod extends StateNotifier<ScheduleState> {
  ScheduleRiverpod() : super(ScheduleState());

  final _scheduleRepository = getIT<ScheduleRepository>();

  Future<void> getSchedule(String groupId) async {
    state = state.copyWith(isLoading: true);
    try {
      final schedule = await _scheduleRepository.getSchedule(groupId);
      state = state.copyWith(
        isLoading: false,
        scheduleList: schedule,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
