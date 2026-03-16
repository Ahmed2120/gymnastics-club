import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymnastics_club/core/theme/app_colors.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/features/profile/profile_controller/attendance_riverpod.dart';
import 'package:gymnastics_club/features/profile/profile_controller/child_riverpod.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import '../widgets/shimmer_widgets.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(childRiverpod, (previous, next) {
      if (previous?.selectedChild?.id != next.selectedChild?.id) {
        _fetchData();
      }
    });

    final attendanceState = ref.watch(attendanceRiverpod);
    final attendance = attendanceState.attendanceList;

    // Sort and build day data
    final sortedAttendance = [...attendance]
      ..sort((a, b) => (a.date ?? DateTime(0)).compareTo(b.date ?? DateTime(0)));

    final days = sortedAttendance
        .where((e) => e.date != null)
        .map((e) => DayData(
              number: e.date!.day,
              color: (e.didAttend ?? false) ? Colors.green : Colors.red,
              status: (e.didAttend ?? false) ? DayStatus.completed : DayStatus.missed,
            ))
        .toList();

    // Add upcoming days
    final now = DateTime.now();
    DateTime lastDay = now;
    if (sortedAttendance.isNotEmpty) {
      final validDates = sortedAttendance.map((e) => e.date).whereType<DateTime>();
      if (validDates.isNotEmpty) {
        lastDay = validDates.reduce((a, b) => a.isAfter(b) ? a : b);
      }
    }
    for (int i = 1; i <= 5; i++) {
      final upcomingDate = lastDay.add(Duration(days: i));
      days.add(DayData(
        number: upcomingDate.day,
        color: colorScheme.surfaceVariant,
        status: DayStatus.upcoming,
      ));
    }

    final totalDays = attendance.length;
    final attendedDays = attendance.where((e) => e.didAttend ?? false).length;
    final missedDays = totalDays - attendedDays;
    final attendancePercentage =
        totalDays > 0 ? (attendedDays / totalDays * 100).toInt() : 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA),
      body: Column(
        children: [
          // ── Curved Header ──────────────────────────────────────────────────
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Top row: back + title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded,
                                  color: Colors.white),
                              onPressed: () => context.pop(),
                            ),
                            const Expanded(
                              child: MainText(
                                'الحضور والغياب',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Attendance rate pill (big highlight)
                      if (!attendanceState.isLoading && totalDays > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.pie_chart_rounded,
                                  color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              MainText(
                                'نسبة الحضور: $attendancePercentage%',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else
                        const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryColor,
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
                                      size: 72, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  const MainText(
                                    'لا توجد بيانات حضور لهذا اللاعب',
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Calendar card
                              HabitCalendarWidget(days: days),
                              24.ph,

                              // Stats section label
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.bar_chart_rounded,
                                        color: AppColors.primaryColor, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  const MainText(
                                    'إحصائيات الشهر',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                              16.ph,

                              // Stats grid
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1.5,
                                children: [
                                  _buildStatCard(
                                    value: '$attendancePercentage%',
                                    label: 'نسبة الحضور',
                                    icon: Icons.pie_chart_rounded,
                                    color: const Color(0xFF667EEA),
                                    isDark: isDark,
                                  ),
                                  _buildStatCard(
                                    value: totalDays.toString(),
                                    label: 'إجمالي الحصص',
                                    icon: Icons.event_available_rounded,
                                    color: const Color(0xFF764BA2),
                                    isDark: isDark,
                                  ),
                                  _buildStatCard(
                                    value: attendedDays.toString(),
                                    label: 'حضور',
                                    icon: Icons.check_circle_rounded,
                                    color: const Color(0xFF16A34A),
                                    isDark: isDark,
                                  ),
                                  _buildStatCard(
                                    value: missedDays.toString(),
                                    label: 'غياب',
                                    icon: Icons.cancel_rounded,
                                    color: const Color(0xFFDC2626),
                                    isDark: isDark,
                                  ),
                                ],
                              ),

                              if (attendanceState.isLoadingMore) ...[
                                16.ph,
                                MainShimmer.single(height: 80),
                              ],
                              const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MainShimmer.calendar(),
          24.ph,
          const Skeleton(height: 25, width: 150),
          16.ph,
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.5,
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
  }) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : color.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
        // Subtle top accent
        border: Border(top: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainText(
                value,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              MainText(
                label,
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Habit Calendar Widget ────────────────────────────────────────────────────

class HabitCalendarWidget extends StatelessWidget {
  final List<DayData> days;

  const HabitCalendarWidget({Key? key, required this.days}) : super(key: key);

  final List<String> dayNames = const ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calendar_month_rounded,
                        color: AppColors.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  MainText(
                    // Show current month name in Arabic
                    DateFormat('MMMM yyyy', 'ar').format(now),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              _buildLegend(isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Day name headers
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
              child: Text(
                dayNames[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Day circles
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) => DayCircle(day: days[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Row(
      children: [
        _legendDot(const Color(0xFF16A34A), 'حضور', isDark),
        const SizedBox(width: 10),
        _legendDot(const Color(0xFFDC2626), 'غياب', isDark),
        const SizedBox(width: 10),
        _legendDot(Colors.grey.shade300, 'قادم', isDark),
      ],
    );
  }

  Widget _legendDot(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// ─── Day Circle Widget ────────────────────────────────────────────────────────

class DayCircle extends StatelessWidget {
  final DayData day;

  const DayCircle({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bgColor() {
      switch (day.status) {
        case DayStatus.completed:
          return const Color(0xFF16A34A);
        case DayStatus.missed:
          return const Color(0xFFDC2626);
        case DayStatus.upcoming:
          return colorScheme.surfaceVariant;
      }
    }

    Color textColor() => day.status == DayStatus.upcoming
        ? colorScheme.onSurfaceVariant
        : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor(),
        shape: BoxShape.circle,
        boxShadow: day.status == DayStatus.upcoming
            ? null
            : [
                BoxShadow(
                  color: bgColor().withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Center(
        child: Text(
          day.number.toString(),
          style: TextStyle(
            color: textColor(),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────

class DayData {
  final int number;
  final Color color;
  final DayStatus status;

  DayData({required this.number, required this.color, required this.status});
}

enum DayStatus { completed, missed, upcoming }
