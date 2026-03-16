import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import '../../../core/utils/date_converter.dart';
import '../../../data/models/models/schedule_model.dart';
import '../../profile/profile_controller/child_riverpod.dart';
import '../../schedule/schedule_controller/schedule_riverpod.dart';

class TrainingCountdown extends ConsumerStatefulWidget {
  const TrainingCountdown({super.key});

  @override
  ConsumerState<TrainingCountdown> createState() => _TrainingCountdownState();
}

class _TrainingCountdownState extends ConsumerState<TrainingCountdown> {
  Timer? _timer;
  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Initial calculation
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    final scheduleState = ref.read(scheduleRiverpod);
    if (scheduleState.scheduleList.isEmpty) {
      if (_countdownText != '') setState(() => _countdownText = '');
      return;
    }

    final nextSession = _getNextSession(scheduleState.scheduleList);
    if (nextSession == null) {
      if (_countdownText != '') setState(() => _countdownText = '');
      return;
    }

    final now = DateTime.now();
    final difference = nextSession.difference(now);

    String newText;
    if (difference.isNegative) {
      newText = 'بدأ التدريب الآن';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      newText = 'يبدأ خلال ';
      if (hours > 0) newText += '$hours ساعة و ';
      newText += '$minutes دقيقة';
    }

    if (_countdownText != newText) {
      setState(() => _countdownText = newText);
    }
  }

  DateTime? _getNextSession(List<ScheduleModel> schedules) {
    if (schedules.isEmpty) return null;

    final now = DateTime.now();
    List<DateTime> upcomingDates = [];

    for (var session in schedules) {
      final tod = DateConverter.parseTimeToTimeOfDay(session.startTime);
      if (tod == null) continue;

      final weekday = _getDayNumber(session.day);
      
      // Find the next occurrence of this weekday
      DateTime scheduledDate = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      int daysUntil = (weekday - now.weekday + 7) % 7;
      
      if (daysUntil == 0) {
        // It's today. Check if time has passed
        if (scheduledDate.isBefore(now)) {
          daysUntil = 7; // Next week
        }
      }
      
      scheduledDate = scheduledDate.add(Duration(days: daysUntil));
      upcomingDates.add(scheduledDate);
    }

    if (upcomingDates.isEmpty) return null;
    upcomingDates.sort();
    return upcomingDates.first;
  }

  int _getDayNumber(String day) {
    switch (day.trim()) {
      case 'الاثنين': return 1;
      case 'الثلاثاء': return 2;
      case 'الأربعاء': return 3;
      case 'الخميس': return 4;
      case 'الجمعة': return 5;
      case 'السبت': return 6;
      case 'الأحد': 
      case 'الاحد': return 7;
      default: return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleRiverpod);
    final childState = ref.watch(childRiverpod);
    final user = childState.selectedChild;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Trigger update when schedule changes
    ref.listen(scheduleRiverpod, (previous, next) {
      _updateCountdown();
    });

    if (scheduleState.scheduleList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: MainText('لا يوجد تدريبات حالياً')),
      );
    }

    final session = scheduleState.scheduleList.first;

    return Row(
      children: [
        Expanded(
          child: _buildActivityCard(
            'التدريب القادم',
            _countdownText.isNotEmpty ? _countdownText : '${session.day} ${session.startTime}',
            Icons.run_circle_outlined,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActivityCard(
            'المجموعة',
            user?.groupName ?? 'مجموعة غير محددة',
            Icons.groups_outlined,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(String title, String subtitle, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 30),
          const SizedBox(height: 12),
          MainText(
            title,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          MainText(
            subtitle,
            fontSize: 11,
            color: Colors.grey,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
