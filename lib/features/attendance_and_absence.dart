import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/features/profile/profile_controller/attendance_riverpod.dart';
import 'package:gymnastics_club/features/profile/profile_controller/child_riverpod.dart';
import 'package:gymnastics_club/widgets/main_text.dart';
import '../../../../widgets/shimmer_widgets.dart';

class AttendanceAndAbsenceScreen extends ConsumerStatefulWidget {
  const AttendanceAndAbsenceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AttendanceAndAbsenceScreen> createState() =>
      _AttendanceAndAbsenceScreenState();
}

class _AttendanceAndAbsenceScreenState
    extends ConsumerState<AttendanceAndAbsenceScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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
    ref.listen(childRiverpod, (previous, next) {
      if (previous?.selectedChild?.id != next.selectedChild?.id) {
        _fetchData();
      }
    });
    final attendanceState = ref.watch(attendanceRiverpod);
    final attendance = attendanceState.attendanceList;

    // Convert AttendanceModel to DayData
    final days = attendance
        .map(
          (e) => DayData(
            number: e.date.day,
            color: e.didAttend ? Colors.green : Colors.red,
            status: e.didAttend ? DayStatus.completed : DayStatus.missed,
          ),
        )
        .toList();

    // Add some upcoming days to make it look like a calendar
    if (days.isNotEmpty) {
      final lastDay = attendance
          .map((e) => e.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      for (int i = 1; i <= 5; i++) {
        days.add(
          DayData(
            number: lastDay.add(Duration(days: i)).day,
            color: Colors.grey[300]!,
            status: DayStatus.upcoming,
          ),
        );
      }
    }

    final totalDays = attendance.length;
    final attendedDays = attendance.where((e) => e.didAttend).length;
    final missedDays = totalDays - attendedDays;
    final attendancePercentage = totalDays > 0
        ? (attendedDays / totalDays * 100).toInt()
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const MainText('الحضور والغياب', fontWeight: FontWeight.bold),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchData();
        },
        child: attendanceState.isLoading
            ? _buildShimmerLoading()
            : attendance.isEmpty
            ? const Center(child: MainText('لا توجد بيانات حضور لهذا اللاعب'))
            : SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HabitCalendarWidget(days: days),
                    24.ph,
                    const MainText(
                      'إحصائيات الشهر',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    16.ph,
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          value: '$attendancePercentage%',
                          label: 'نسبة الحضور',
                          icon: Icons.pie_chart_rounded,
                          color: const Color(0xFF667EEA),
                        ),
                        _buildStatCard(
                          value: totalDays.toString(),
                          label: 'إجمالي الحصص',
                          icon: Icons.event_available_rounded,
                          color: const Color(0xFF764BA2),
                        ),
                        _buildStatCard(
                          value: attendedDays.toString(),
                          label: 'حضور',
                          icon: Icons.check_circle_rounded,
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          value: missedDays.toString(),
                          label: 'غياب',
                          icon: Icons.cancel_rounded,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    24.ph,
                    if (attendanceState.isLoadingMore)
                      MainShimmer.single(height: 80),
                  ],
                ),
              ),
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainText(
                value,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              MainText(label, fontSize: 12, color: Colors.grey.shade600),
            ],
          ),
        ],
      ),
    );
  }
}

class HabitCalendarWidget extends StatelessWidget {
  final List<DayData> days;

  const HabitCalendarWidget({Key? key, required this.days}) : super(key: key);

  final List<String> dayNames = const [
    'س', // Saturday
    'ح', // Sunday
    'ن', // Monday
    'ث', // Tuesday
    'ر', // Wednesday
    'خ', // Thursday
    'ج', // Friday
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const MainText(
                'التقويم',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              _buildLegend(),
            ],
          ),
          20.ph,
          // Days Header
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  dayNames[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
              );
            },
          ),
          8.ph,
          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              return DayCircle(day: days[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(Colors.green.shade400, 'حضور'),
        12.pw,
        _legendItem(Colors.red.shade400, 'غياب'),
        12.pw,
        _legendItem(Colors.grey.shade200, 'قادم'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        4.pw,
        MainText(label, fontSize: 10, color: Colors.grey.shade600),
      ],
    );
  }
}

// Day Circle Widget
class DayCircle extends StatelessWidget {
  final DayData day;

  const DayCircle({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getBgColor() {
      switch (day.status) {
        case DayStatus.completed:
          return Colors.green.shade400;
        case DayStatus.missed:
          return Colors.red.shade400;
        case DayStatus.upcoming:
          return Colors.grey.shade100;
      }
    }

    Color getTextColor() {
      return day.status == DayStatus.upcoming
          ? Colors.grey.shade500
          : Colors.white;
    }

    return Container(
      decoration: BoxDecoration(
        color: getBgColor(),
        shape: BoxShape.circle,
        boxShadow: day.status == DayStatus.upcoming
            ? null
            : [
                BoxShadow(
                  color: getBgColor().withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Center(
        child: Text(
          day.number.toString(),
          style: TextStyle(
            color: getTextColor(),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Data Models
class DayData {
  final int number;
  final Color color;
  final DayStatus status;

  DayData({required this.number, required this.color, required this.status});
}

enum DayStatus { completed, missed, upcoming }
