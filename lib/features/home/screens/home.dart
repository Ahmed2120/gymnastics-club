import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/widgets/main_text.dart';

import '../../../core/costants/app_assets.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../profile/profile_controller/child_riverpod.dart';
import '../../schedule/schedule_controller/schedule_riverpod.dart';
import '../news_controller/news_riverpod.dart';
import '../../../core/utils/date_converter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _fetchNews();
    _fetchChildData();
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
      ref.read(newsRiverpod.notifier).loadMoreNews();
    }
  }

  void _fetchNews() {
    Future.microtask(() {
      ref.read(newsRiverpod.notifier).getNews();
    });
  }

  void _fetchChildData() {
    Future.microtask(() {
      final child = ref.read(childRiverpod).selectedChild;
      if (child != null) {
        ref.read(scheduleRiverpod.notifier).getSchedule(child.group);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(childRiverpod, (previous, next) {
      if (previous?.selectedChild?.id != next.selectedChild?.id) {
        _fetchChildData();
      }
    });

    return Scaffold(
      appBar: AppBar(title: MainText('الرئيسية'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(newsRiverpod.notifier).getNews();
          _fetchChildData();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764BA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MainText(
                                  'hello_again'.tr(),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                8.ph,
                                Consumer(
                                  builder: (context, ref, _) {
                                    final activeChild = ref
                                        .watch(childRiverpod)
                                        .selectedChild;
                                    return MainText(
                                      activeChild?.name ?? 'اسم اللاعب',
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const MainText('👋', fontSize: 32),
                          ),
                        ],
                      ),
                    ),
                    22.ph,
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7FB6FD), Color(0xFFC0DAFB)],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF667eea),
                            ),
                            child: const MainText('🏃', fontSize: 24),
                          ),
                          12.pw,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MainText(
                                  'التدريب القادم'.tr(),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1565c0),
                                ),
                                12.ph,
                                Consumer(
                                  builder: (context, ref, _) {
                                    final scheduleState = ref.watch(
                                      scheduleRiverpod,
                                    );
                                    if (scheduleState.isLoading) {
                                      return const MainText(
                                        'جاري التحميل...',
                                        fontSize: 14,
                                      );
                                    }
                                    if (scheduleState.scheduleList.isEmpty) {
                                      return const MainText(
                                        'لا يوجد تدريبات قريبة',
                                        fontSize: 14,
                                      );
                                    }

                                    // Logic to find real next session
                                    final now = DateTime.now();
                                    final currentWeekday = now.weekday;

                                    final dayMap = {
                                      'الاثنين': 1,
                                      'الثلاثاء': 2,
                                      'الأربعاء': 3,
                                      'الخميس': 4,
                                      'الجمعة': 5,
                                      'السبت': 6,
                                      'الأحد': 7,
                                    };

                                    final sortedSessions = [
                                      ...scheduleState.scheduleList,
                                    ];

                                    // Find session for today or next possible day
                                    dynamic nextSession;

                                    // Start searching from today
                                    for (int i = 0; i < 7; i++) {
                                      int targetWeekday =
                                          (currentWeekday + i - 1) % 7 + 1;
                                      final sessionsOnDay = sortedSessions
                                          .where(
                                            (s) =>
                                                dayMap[s.day] == targetWeekday,
                                          )
                                          .toList();

                                      if (sessionsOnDay.isNotEmpty) {
                                        if (i == 0) {
                                          // Today - check time
                                          for (var s in sessionsOnDay) {
                                            if (DateConverter.isTimeAfter(
                                              s.startTime,
                                              now,
                                            )) {
                                              nextSession = s;
                                              break;
                                            }
                                          }
                                          if (nextSession != null) break;
                                        } else {
                                          // Next day session found
                                          nextSession = sessionsOnDay.first;
                                          break;
                                        }
                                      }
                                    }

                                    nextSession ??=
                                        scheduleState.scheduleList.first;

                                    return MainText(
                                      '${nextSession.day} الساعة ${nextSession.startTime}',
                                      fontSize: 14,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    22.ph,
                    MainText(
                      'آخر الأخبار'.tr(),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    22.ph,
                  ],
                ),
              ),
            ),
            Consumer(
              builder: (context, ref, _) {
                final newsState = ref.watch(newsRiverpod);
                if (newsState.isLoading) {
                  return SliverToBoxAdapter(child: MainShimmer.list());
                } else if (newsState.error.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(child: MainText(newsState.error.toString())),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == newsState.newsList.length) {
                          return MainShimmer.single(height: 250);
                        }
                        final item = newsState.newsList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MainText(
                                  item.title,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                12.ph,
                                MainText(
                                  item.newsContent,
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                12.ph,
                                SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      AppAssets.achievement,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount:
                          newsState.newsList.length +
                          (newsState.isLoadingMore ? 1 : 0),
                    ),
                  ),
                );
              },
            ),
            // const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
