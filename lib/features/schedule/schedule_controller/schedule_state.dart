import '../../../data/models/models/schedule_model.dart';

class ScheduleState {
  final bool isLoading;
  final List<ScheduleModel> scheduleList;
  final String error;

  ScheduleState({
    this.scheduleList = const [],
    this.error = '',
    this.isLoading = false,
  });

  ScheduleState copyWith({
    List<ScheduleModel>? scheduleList,
    String? error,
    bool? isLoading,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      scheduleList: scheduleList ?? this.scheduleList,
      error: error ?? this.error,
    );
  }
}
