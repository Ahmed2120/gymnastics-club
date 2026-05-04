import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/utils/date_converter.dart';
import '../../../data/models/models/schedule_model.dart';
import '../../profile/profile_controller/child_riverpod.dart';
import '../../schedule/schedule_controller/schedule_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/local_storage_service.dart';
import 'reminder_bottom_sheet.dart';

class TrainingCountdown extends ConsumerStatefulWidget {
  const TrainingCountdown({super.key});

  @override
  ConsumerState<TrainingCountdown> createState() => _TrainingCountdownState();
}

class _TrainingCountdownState extends ConsumerState<TrainingCountdown> {
  Timer? _timer;
  ScheduleModel? _nextSessionModel;
  DateTime? _nextSessionDateTime;
  bool _isToday = false;
  String _hoursText = '00';
  String _minutesText = '00';
  
  bool _isReminderEnabled = false;
  int _reminderOffset = 60;

  @override
  void initState() {
    super.initState();
    _loadReminderState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateCountdown());
  }

  void _loadReminderState() {
    setState(() {
      _isReminderEnabled = LocalStorageService.isReminderEnabled();
      _reminderOffset = LocalStorageService.getReminderOffset();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) _updateCountdown();
    });
  }

  void _updateCountdown() {
    final scheduleList = ref.read(scheduleRiverpod).scheduleList;
    if (scheduleList.isEmpty) return;

    final next = _getNextSessionData(scheduleList);
    if (next == null) return;

    final now = DateTime.now();
    final nextDate = next.dateTime;
    
    final bool isToday = nextDate.year == now.year && 
                         nextDate.month == now.month && 
                         nextDate.day == now.day;

    final difference = nextDate.difference(now);
    
    setState(() {
      _nextSessionModel = next.model;
      _nextSessionDateTime = nextDate;
      _isToday = isToday;
      
      if (!difference.isNegative) {
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        _hoursText = hours.toString().padLeft(2, '0');
        _minutesText = minutes.toString().padLeft(2, '0');
      } else {
        _hoursText = '00';
        _minutesText = '00';
      }
    });

    // If reminder is enabled but session changed, we might need to reschedule.
    // For simplicity, we just keep it synchronized when the user sets it.
  }

  _SessionData? _getNextSessionData(List<ScheduleModel> schedules) {
    if (schedules.isEmpty) return null;
    final now = DateTime.now();
    List<_SessionData> upcoming = [];

    for (var session in schedules) {
      final tod = DateConverter.parseTimeToTimeOfDay(session.startTime);
      if (tod == null) continue;
      final weekday = DateConverter.getWeekdayFromArabic(session.day);
      
      DateTime scheduledDate = DateTime(
          now.year, now.month, now.day, tod.hour, tod.minute);
      
      int daysUntil = (weekday - now.weekday + 7) % 7;
      
      if (daysUntil == 0 && scheduledDate.isBefore(now)) {
        daysUntil = 7;
      }
      
      scheduledDate = scheduledDate.add(Duration(days: daysUntil));
      upcoming.add(_SessionData(dateTime: scheduledDate, model: session));
    }

    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcoming.first;
  }

  Future<void> _showReminderSettings() async {
    await ReminderBottomSheet.show(
      context: context,
      currentOffset: _reminderOffset,
      isEnabled: _isReminderEnabled,
      onSetReminder: (minutes) async {
        await _toggleReminder(true, minutes);
      },
      onCancelReminder: () async {
        await _toggleReminder(false, _reminderOffset);
      },
    );
  }

  Future<void> _toggleReminder(bool enabled, int offset) async {
    if (_nextSessionDateTime == null) return;

    if (enabled) {
      // Ensure we have permissions first
      final bool hasPermission = await NotificationService.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: MainText('يجب الموافقة على الأذونات لتفعيل التنبيهات', color: Colors.white),
              backgroundColor: AppColors.primaryCrimson,
            ),
          );
        }
        return;
      }

      final notificationTime = _nextSessionDateTime!.subtract(Duration(minutes: offset));
      
      if (notificationTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: MainText('لا يمكن ضبط تنبيه لوقت مضى', color: Colors.white)),
        );
        return;
      }

      await NotificationService.scheduleNotification(
        id: 1001, // Unique ID for training reminder
        title: 'تنبيه التدريب 🤸',
        body: 'بطلنا الصغير، التدريب هيبدأ بعد $offset دقيقة. جاهز؟',
        scheduledDate: notificationTime,
      );

      await LocalStorageService.setReminderEnabled(true);
      await LocalStorageService.setReminderOffset(offset);
      
      setState(() {
        _isReminderEnabled = true;
        _reminderOffset = offset;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryColor,
            content: MainText('تم ضبط التنبيه بنجاح قبل التدريب بـ $offset دقيقة', color: Colors.white, fontSize: 14),
          ),
        );
      }
    } else {
      await NotificationService.cancelNotification(1001);
      await LocalStorageService.setReminderEnabled(false);
      
      setState(() {
        _isReminderEnabled = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: MainText('تم إلغاء التنبيه', color: Colors.white)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleRiverpod);
    final childState = ref.watch(childRiverpod);
    final user = childState.selectedChild;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(scheduleRiverpod, (previous, next) => _updateCountdown());

    if (scheduleState.scheduleList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFF10141D),
        borderRadius: BorderRadius.circular(40),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryCrimson.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: MainText(
                  'التدريب القادم',
                  color: AppColors.primaryCrimson,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                children: [
                  // Reminder Toggle
                  GestureDetector(
                    onTap: _showReminderSettings,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isReminderEnabled 
                            ? AppColors.primaryCrimson.withOpacity(0.2) 
                            : Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Pulse(
                        infinite: _isReminderEnabled,
                        animate: _isReminderEnabled,
                        child: Icon(
                          _isReminderEnabled ? Icons.notifications_active : Icons.notifications_outlined,
                          color: _isReminderEnabled ? AppColors.primaryCrimson : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sports_gymnastics,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          MainText(
            user?.groupName ?? '',
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),

          const SizedBox(height: 24),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainText(
                _isToday ? 'يبدأ التدريب خلال' : 'موعد التدريب القادم',
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 4),
              if (_isToday)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    MainText(
                      _minutesText,
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                    const SizedBox(width: 4),
                    const MainText(
                      ':',
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                    const SizedBox(width: 4),
                    MainText(
                      _hoursText,
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                    const SizedBox(width: 8),
                    MainText(
                      'ساعة',
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                )
              else
                MainText(
                  '${_nextSessionModel?.day ?? ''} - ${DateConverter.formatTimeArabic(_nextSessionModel?.startTime)}',
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionData {
  final DateTime dateTime;
  final ScheduleModel model;
  _SessionData({required this.dateTime, required this.model});
}
