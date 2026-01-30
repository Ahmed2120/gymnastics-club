import 'package:flutter_riverpod/legacy.dart';
import 'package:gymnastics_club/core/services/init_getit.dart';
import '../../../data/repositories/attendance_repository.dart';
import 'attendance_state.dart';

final attendanceRiverpod =
    StateNotifierProvider.autoDispose<AttendanceRiverpod, AttendanceState>((
      ref,
    ) {
      return AttendanceRiverpod();
    });

class AttendanceRiverpod extends StateNotifier<AttendanceState> {
  AttendanceRiverpod() : super(AttendanceState());

  final _attendanceRepository = getIT<AttendanceRepository>();

  Future<void> getAttendance(int childId) async {
    state = state.copyWith(isLoading: true, currentPage: 1, hasMore: true);
    try {
      final attendance = await _attendanceRepository.getAttendance(
        childId,
        page: 1,
      );
      state = state.copyWith(
        isLoading: false,
        attendanceList: attendance,
        currentPage: 2,
        hasMore: attendance.length >= 10,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMoreAttendance(int childId) async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final attendance = await _attendanceRepository.getAttendance(
        childId,
        page: state.currentPage,
      );
      state = state.copyWith(
        isLoadingMore: false,
        attendanceList: [...state.attendanceList, ...attendance],
        currentPage: state.currentPage + 1,
        hasMore: attendance.length >= 10,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}
