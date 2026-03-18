import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/data/models/models/attendance_model.dart';
import 'package:gymnastics_club/features/profile/profile_controller/attendance_riverpod.dart';
import 'package:gymnastics_club/features/profile/profile_controller/child_riverpod.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import '../widgets/shimmer_widgets.dart';

import '../widgets/custom_back_button.dart';

class AttendanceAndAbsenceScreen extends ConsumerStatefulWidget {
  const AttendanceAndAbsenceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AttendanceAndAbsenceScreen> createState() =>
      _AttendanceAndAbsenceScreenState();
}

class _AttendanceAndAbsenceScreenState
    extends ConsumerState<AttendanceAndAbsenceScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _fetchData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final child = ref.read(childRiverpod).selectedChild;
      if (child != null) {
        ref.read(attendanceRiverpod.notifier).loadMoreAttendance(child.id);
      }
    }
  }

  void _fetchData() {
    Future.microtask(() {
      final child = ref.read(childRiverpod).selectedChild;
      if (child != null) {
        ref.read(attendanceRiverpod.notifier).getAttendance(child.id);
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

    final attendanceState = ref.watch(attendanceRiverpod);
    final attendance = attendanceState.attendanceList;

    final sortedAttendance = [...attendance]
      ..sort((a, b) => (a.date ?? DateTime(0)).compareTo(b.date ?? DateTime(0)));

    // Show only a single month (latest available, otherwise current) so older
    // pages loaded by pagination don't pollute the calendar grid.
    final DateTime monthToDisplay;
    final latestDate = sortedAttendance
        .map((e) => e.date)
        .whereType<DateTime>()
        .fold<DateTime?>(null, (prev, next) {
      if (prev == null) return next;
      return next.isAfter(prev) ? next : prev;
    });
    monthToDisplay = latestDate ?? DateTime.now();

    final monthAttendance = sortedAttendance
        .where((e) =>
            e.date != null &&
            e.date!.year == monthToDisplay.year &&
            e.date!.month == monthToDisplay.month)
        .toList();

    // Build a map for quick lookup by day.
    final Map<int, AttendanceModel> dayMap = {
      for (final item in monthAttendance) item.date!.day: item
    };

    final endOfMonth = DateTime(monthToDisplay.year, monthToDisplay.month + 1, 0);
    final List<DayData> days = [];

    // Render the full month so there are no visual gaps (e.g., missing 11–15).
    for (int day = 1; day <= endOfMonth.day; day++) {
      final record = dayMap[day];
      if (record != null) {
        final attended = record.didAttend ?? false;
        days.add(DayData(
          number: day,
          color: attended ? const Color(0xFF16A34A) : AppColors.primaryCrimson,
          status: attended ? DayStatus.completed : DayStatus.missed,
        ));
      } else {
        // No record; show as neutral upcoming/placeholder.
        days.add(DayData(
          number: day,
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
          status: DayStatus.upcoming,
        ));
      }
    }

    final displayMonth = monthToDisplay;

    final totalDays = attendance.length;
    final attendedDays = attendance.where((e) => e.didAttend ?? false).length;
    final missedDays = totalDays - attendedDays;
    final attendancePercentage =
        totalDays > 0 ? (attendedDays / totalDays * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
        title: MainText(
          'الحضور والغياب',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.lightText,
        ),
      ),
      body: Column(
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: (!attendanceState.isLoading && totalDays > 0)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE5E5E5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.analytics_rounded,
                                color: AppColors.primaryCrimson, size: 20),
                            const SizedBox(width: 10),
                            MainText(
                              'نسبة الحضور: $attendancePercentage%',
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryCrimson,
              onRefresh: () async => _fetchData(),
              child: attendanceState.isLoading
                  ? _buildShimmerLoading()
                  : attendance.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Column(
                                children: [
                                  Icon(Icons.event_busy_rounded,
                                      size: 80, color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]),
                                  const SizedBox(height: 24),
                                  MainText(
                                    'لا توجد بيانات حضور لهذا اللاعب',
                                    color: isDark ? Colors.white24 : Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HabitCalendarWidget(days: days, month: displayMonth),
                              32.ph,

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryCrimson.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.bar_chart_rounded,
                                        color: AppColors.primaryCrimson, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  MainText(
                                    'إحصائيات الشهر',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ],
                              ),
                              24.ph,

                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.15,
                                children: [
                                  _buildStatCard(
                                    value: totalDays.toString(),
                                    label: 'إجمالي الحصص',
                                    icon: Icons.calendar_today_rounded,
                                    color: const Color(0xFF8B5CF6),
                                    isDark: isDark,
                                  ),
                                  _buildStatCard(
                                    value: '$attendancePercentage%',
                                    label: 'نسبة الحضور',
                                    icon: Icons.stars_rounded,
                                    color: AppColors.primaryCrimson,
                                    isDark: isDark,
                                  ),
                                  _buildStatCard(
                                    value: missedDays.toString(),
                                    label: 'عدد الغياب',
                                    icon: Icons.cancel,
                                    color: AppColors.primaryCrimson,
                                    isDark: isDark,
                                    isColoredBackground: true,
                                  ),
                                  _buildStatCard(
                                    value: attendedDays.toString(),
                                    label: 'عدد الحضور',
                                    icon: Icons.check_circle,
                                    color: const Color(0xFF10B981),
                                    isDark: isDark,
                                    isColoredBackground: true,
                                  ),
                                ],
                              ),

                              if (attendanceState.isLoadingMore) ...[
                                24.ph,
                                MainShimmer.single(height: 100),
                              ],
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MainShimmer.calendar(),
          32.ph,
          const Skeleton(height: 30, width: 180),
          24.ph,
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
            children: List.generate(4, (index) => MainShimmer.statCard()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    bool isColoredBackground = false,
  }) {
    final bgColor = isColoredBackground 
        ? color.withOpacity(isDark ? 0.15 : 0.05) 
        : (isDark ? AppColors.darkSurface : Colors.white);
    
    final borderColor = isColoredBackground
        ? color.withOpacity(isDark ? 0.3 : 0.1)
        : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1));

    final textColor = isColoredBackground
        ? color
        : (isDark ? Colors.white : const Color(0xFF1E293B));

    final labelColor = isColoredBackground
        ? color.withOpacity(0.8)
        : (isDark ? Colors.white54 : Colors.grey[500]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isColoredBackground ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: isColoredBackground ? EdgeInsets.zero : const EdgeInsets.all(10),
            decoration: isColoredBackground ? null : BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: isColoredBackground ? 32 : 24),
          ),
          const SizedBox(height: 12),
          MainText(
            value,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
          const SizedBox(height: 4),
          MainText(
            label,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: labelColor,
          ),
        ],
      ),
    );
  }
}

class HabitCalendarWidget extends StatelessWidget {
  final List<DayData> days;
  final DateTime month;
  const HabitCalendarWidget({Key? key, required this.days, required this.month}) : super(key: key);

  final List<String> dayNames = const ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayMonth = month;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCrimson.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        color: AppColors.primaryCrimson, size: 20),
                  ),
                  const SizedBox(width: 12),
                  MainText(
                    DateFormat('MMMM yyyy', 'ar').format(displayMonth),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 7,
            itemBuilder: (context, index) => Center(
              child: MainText(
                dayNames[index],
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white24 : Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) => DayCircle(day: days[index]),
          ),
          
          const SizedBox(height: 24),
          _buildLegend(isDark),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(const Color(0xFF10B981), 'حضور', isDark),
        const SizedBox(width: 20),
        _legendDot(AppColors.primaryCrimson, 'غياب', isDark),
        const SizedBox(width: 20),
        _legendDot(isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade100, 'قادم', isDark),
      ],
    );
  }

  Widget _legendDot(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        MainText(
          label,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white38 : Colors.grey[600],
        ),
      ],
    );
  }
}

class DayCircle extends StatelessWidget {
  final DayData day;
  const DayCircle({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor() {
      switch (day.status) {
        case DayStatus.completed:
          return const Color(0xFF10B981);
        case DayStatus.missed:
          return AppColors.primaryCrimson;
        case DayStatus.upcoming:
          return isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100;
      }
    }

    Color textColor() {
      if (day.status == DayStatus.upcoming) {
        return isDark ? Colors.white12 : Colors.grey.shade300;
      }
      return Colors.white;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor(),
        shape: BoxShape.circle,
        boxShadow: day.status == DayStatus.upcoming
            ? null
            : [
                BoxShadow(
                  color: bgColor().withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Center(
        child: MainText(
          day.number.toString(),
          color: textColor(),
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class DayData {
  final int number;
  final Color color;
  final DayStatus status;

  DayData({required this.number, required this.color, required this.status});
}

enum DayStatus { completed, missed, upcoming }
