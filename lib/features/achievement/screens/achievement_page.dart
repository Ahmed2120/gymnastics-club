import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymnastics_club/core/utils/extensions/size_extensions.dart';
import 'package:gymnastics_club/features/achievement/achievement_controller/achievement_riverpod.dart';
import 'package:gymnastics_club/features/profile/profile_controller/child_riverpod.dart';

import '../../../widgets/main_text.dart';
import '../../../widgets/shimmer_widgets.dart';

class AchievementPage extends ConsumerStatefulWidget {
  const AchievementPage({super.key});

  @override
  ConsumerState<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends ConsumerState<AchievementPage> {
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
        ref.read(achievementRiverpod.notifier).loadMoreAchievements(child.id);
      }
    }
  }

  void _fetchData() {
    Future.microtask(() {
      final child = ref.read(childRiverpod).selectedChild;
      if (child != null) {
        ref.read(achievementRiverpod.notifier).getAchievements(child.id);
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
    final achievementState = ref.watch(achievementRiverpod);
    final achievements = achievementState.achievementList;
    return Scaffold(
      appBar: AppBar(title: MainText('الإنجازات'), centerTitle: true),
      body: achievementState.isLoading
          ? MainShimmer.achievementCard()
          : achievements.isEmpty
          ? const Center(child: MainText('لا يوجد إنجازات لهذا البطل حالياً'))
          : ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  achievements.length +
                  (achievementState.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => 12.ph,
              itemBuilder: (context, index) {
                if (index == achievements.length) {
                  return MainShimmer.single(height: 100);
                }
                final item = achievements[index];
                return FadeInUp(
                  duration: const Duration(seconds: 1),
                  delay: Duration(milliseconds: 100 * index),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFD700), // gold
                                Color(0xFFFFED4E), // light gold
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const MainText('🥇', fontSize: 30),
                        ),
                        12.pw,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MainText(
                                item.title.tr(),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF667eea),
                              ),
                              12.ph,
                              MainText(
                                DateFormat(
                                  'd MMMM yyyy',
                                  'ar',
                                ).format(item.date),
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              12.ph,
                              MainText(item.venue, fontSize: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
