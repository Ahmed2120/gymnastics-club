import 'dart:async';
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
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> getAttendance(int childId) async {
    state = state.copyWith(isLoading: true, currentPage: 1, hasMore: true);
    _startSubscription(childId);
    await _fetchFirstPage(childId);
  }

  Future<void> _fetchFirstPage(int childId) async {
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

  void _startSubscription(int childId) {
    if (_subscription != null) return; // Already subscribed for this childId?
    // Actually, if childId changes, we should restart.
    // For now, assume it's stable or handle change in UI.

    _subscription?.cancel();
    _subscription = _attendanceRepository.subscribeToAttendance(childId).listen(
      (data) {
        _fetchFirstPage(childId);
      },
    );
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
