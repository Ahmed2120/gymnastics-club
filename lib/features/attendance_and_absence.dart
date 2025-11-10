import 'package:flutter/material.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_text.dart';

class AttendanceAndAbsenceScreen extends StatelessWidget {
  const AttendanceAndAbsenceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = [
      DayData(number: 4, color: Colors.grey[300]!, status: DayStatus.upcoming),
      DayData(number: 3, color: Colors.green, status: DayStatus.completed),
      DayData(number: 2, color: Colors.grey[300]!, status: DayStatus.upcoming),
      DayData(number: 1, color: Colors.green, status: DayStatus.completed),
      DayData(number: 11, color: Colors.grey[300]!, status: DayStatus.upcoming),
      DayData(number: 10, color: Colors.blue, status: DayStatus.completed),
      DayData(number: 9, color: Colors.red, status: DayStatus.missed),
      DayData(number: 8, color: Colors.grey[300]!, status: DayStatus.upcoming),
      DayData(number: 7, color: Colors.green, status: DayStatus.completed),
      DayData(number: 6, color: Colors.grey[300]!, status: DayStatus.upcoming),
      DayData(number: 5, color: Colors.green, status: DayStatus.completed),
    ];

    return Scaffold(
      appBar: AppBar(title: MainText('الحضور والغياب'), centerTitle: true,),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: HabitCalendarWidget(
              days: days,
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const MainText(
                  'إحصائيات الشهر',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),

                16.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      value: '80%',
                      label: 'النسبة',
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      value: 2.toString(),
                      label: 'غياب',
                      color: Colors.red,
                    ),
                    _buildStatItem(
                      value: 8.toString(),
                      label: 'حضور',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          )

        ],
      ),
    );
  }


  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class HabitCalendarWidget extends StatelessWidget {
  final List<DayData> days;

  const HabitCalendarWidget({
    Key? key,
    required this.days,
  }) : super(key: key);

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Days Grid
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              );
            },
          ),

          // const SizedBox(height: 8),

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
            itemBuilder: (context, index) {
              return DayCircle(day: days[index]);
            },
          ),
        ],
      ),
    );
  }

}

// Day Circle Widget
class DayCircle extends StatelessWidget {
  final DayData day;

  const DayCircle({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: day.color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          day.number.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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

  DayData({
    required this.number,
    required this.color,
    required this.status,
  });
}

enum DayStatus {
  completed,
  missed,
  upcoming,
}