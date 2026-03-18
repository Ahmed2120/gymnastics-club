import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/features/profile/profile_controller/child_riverpod.dart';
import 'package:gymnastics_club/features/schedule/schedule_controller/schedule_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/date_converter.dart';
import '../../../widgets/main_text.dart';
import '../../../widgets/shimmer_widgets.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    Future.microtask(() {
      final child = ref.read(childRiverpod).selectedChild;
      if (child != null) {
        ref.read(scheduleRiverpod.notifier).getSchedule(child.groupId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(childRiverpod, (previous, next) {
      if (previous?.selectedChild?.id != next.selectedChild?.id) {
        _fetchData();
      }
    });

    final scheduleState = ref.watch(scheduleRiverpod);
    final scheduleList = scheduleState.scheduleList;

    final now = DateTime.now();
    int? nextIndex;

    final List<DateTime> sessionDates = scheduleList.map((item) {
      final tod = DateConverter.parseTimeToTimeOfDay(item.startTime);
      if (tod == null) return now.add(const Duration(days: 365));
      final weekday = DateConverter.getWeekdayFromArabic(item.day);
      
      DateTime scheduledDate = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      int daysUntil = (weekday - now.weekday + 7) % 7;
      if (daysUntil == 0 && scheduledDate.isBefore(now)) {
        daysUntil = 7;
      }
      return scheduledDate.add(Duration(days: daysUntil));
    }).toList();

    if (sessionDates.isNotEmpty) {
      DateTime minDate = sessionDates[0];
      nextIndex = 0;
      for (int i = 1; i < sessionDates.length; i++) {
        if (sessionDates[i].isBefore(minDate)) {
          minDate = sessionDates[i];
          nextIndex = i;
        }
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        color: AppColors.primaryCrimson,
        onRefresh: () async => _fetchData(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.04),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: AppColors.primaryCrimson, size: 28),
                            const SizedBox(width: 12),
                            MainText(
                              'جدول المواعيد',
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        MainText(
                          'الأسبوع الحالي',
                          color: isDark ? Colors.white38 : Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (scheduleState.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: MainShimmer.list(itemCount: 4, height: 120),
                ),
              )
            else if (scheduleList.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note_outlined, size: 64, color: isDark ? Colors.white10 : Colors.grey.shade200),
                      const SizedBox(height: 16),
                      MainText('لا يوجد جدول مواعيد لهذه المجموعة حالياً',
                          color: isDark ? Colors.white24 : Colors.grey),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = scheduleList[index];
                      final sessionDate = sessionDates[index];
                      final bool isHighlighted = index == nextIndex;
                      final bool isToday = sessionDate.year == now.year && 
                                           sessionDate.month == now.month && 
                                           sessionDate.day == now.day;

                      return FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: Duration(milliseconds: 100 * index),
                        child: Padding(
                           padding: const EdgeInsets.only(bottom: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isHighlighted
                                  ? (isDark ? const Color(0xFF2D1B1B) : const Color(0xFFFEF2F2))
                                  : (isDark ? AppColors.darkSurface : Colors.white),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: isHighlighted
                                    ? AppColors.primaryCrimson.withOpacity(0.3)
                                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time_filled_rounded, color: AppColors.primaryCrimson, size: 28),
                                          const SizedBox(width: 8),
                                          MainText(
                                            isToday ? '${item.day} (اليوم)' : item.day,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: isHighlighted ? AppColors.primaryCrimson : (isDark ? Colors.white : Colors.black87),
                                          ),
                                          if (isHighlighted) ...[
                                            const SizedBox(width: 8),
                                            const Icon(Icons.stars_rounded, color: AppColors.primaryCrimson, size: 24),
                                          ],
                                        ],
                                      ),
                                      MainText(
                                        DateFormat('d MMMM', 'ar').format(sessionDate), 
                                        fontSize: 15,
                                        color: isDark ? Colors.white24 : Colors.grey.withOpacity(0.8),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTimeBox('وقت البدء', item.startTime, isDark, isHighlighted, showArc: true),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildTimeBox('وقت الانتهاء', item.endTime, isDark, isHighlighted, showArc: false),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: scheduleList.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(String label, String time, bool isDark, bool isHighlighted, {bool showArc = true}) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted 
            ? (isDark ? Colors.black.withOpacity(0.4) : Colors.white)
            : (isDark ? Colors.black.withOpacity(0.2) : const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (showArc)
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: 32,
                child: CustomPaint(
                  painter: _TimeArcPainter(
                    color: AppColors.primaryCrimson,
                    width: 6,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MainText(
                  label,
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.grey[500],
                  fontWeight: FontWeight.w900,
                ),
                const SizedBox(height: 8),
                MainText(
                  time.replaceAll('AM', 'ص').replaceAll('PM', 'م'),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeArcPainter extends CustomPainter {
  final Color color;
  final double width;

  _TimeArcPainter({required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    final double h = size.height;
    final double w = size.width;
    const double radius = 32.0;
    
    final double arcStartAngle = -pi * 0.4;
    final double arcSweepAngle = pi * 0.8;

    canvas.drawArc(
      Rect.fromLTRB(w - radius * 2, 4, w, h - 4),
      arcStartAngle,
      arcSweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
