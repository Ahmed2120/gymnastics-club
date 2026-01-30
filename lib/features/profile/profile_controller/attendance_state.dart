import '../../../data/models/models/attendance_model.dart';

class AttendanceState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final List<AttendanceModel> attendanceList;
  final String error;

  AttendanceState({
    this.attendanceList = const [],
    this.error = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
  });

  AttendanceState copyWith({
    List<AttendanceModel>? attendanceList,
    String? error,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      attendanceList: attendanceList ?? this.attendanceList,
      error: error ?? this.error,
    );
  }
}
