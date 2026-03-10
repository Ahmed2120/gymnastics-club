import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/features/profile/profile_controller/child_riverpod.dart';
import 'package:gymnastics_club/features/schedule/schedule_controller/schedule_riverpod.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.05);

    ref.listen(childRiverpod, (previous, next) {
      if (previous?.selectedChild?.id != next.selectedChild?.id) {
        _fetchData();
      }
    });
    final scheduleState = ref.watch(scheduleRiverpod);
    final schedule = scheduleState.scheduleList;
    return Scaffold(
      appBar: AppBar(title: MainText('جدول المواعيد'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchData();
        },
        child: scheduleState.isLoading
            ? MainShimmer.list(itemCount: 4, height: 120)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Transform.flip(
                            flipX:
                                Directionality.of(context) ==
                                ui.TextDirection.rtl,
                            child: Icon(Icons.arrow_left_outlined, size: 40),
                          ),
                          MainText(
                            'الأسبوع الحالي'.tr(),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          Transform.flip(
                            flipX:
                                Directionality.of(context) ==
                                ui.TextDirection.rtl,
                            child: Icon(Icons.arrow_right, size: 40),
                          ),
                        ],
                      ),
                    ),
                    22.ph,
                    if (schedule.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: MainText(
                            'لا يوجد جدول مواعيد لهذه المجموعة حالياً',
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        itemCount: schedule.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => 16.ph,
                        itemBuilder: (context, index) {
                          final item = schedule[index];
                          return FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: Duration(milliseconds: 100 * index),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: shadowColor,
                                    offset: const Offset(0, 8),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? colorScheme.surfaceVariant
                                          : const Color(0xFFF5F7FF),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 18,
                                          color: colorScheme.primary,
                                        ),
                                        10.pw,
                                        MainText(
                                          item.day.tr(),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: _scheduleInfoTile(
                                      icon: Icons.access_time_rounded,
                                      title: 'الوقت',
                                      value:
                                          '${item.startTime} - ${item.endTime}',
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _scheduleInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            6.pw,
            MainText(title, fontSize: 13, color: colorScheme.onSurfaceVariant),
          ],
        ),
        8.ph,
        MainText(value, fontSize: 16, fontWeight: FontWeight.bold),
      ],
    );
  }
}
