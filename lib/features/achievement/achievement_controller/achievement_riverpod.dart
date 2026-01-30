import 'package:flutter_riverpod/legacy.dart';
import 'package:gymnastics_club/core/services/init_getit.dart';
import '../../../data/repositories/achievement_repository.dart';
import 'achievement_state.dart';

final achievementRiverpod =
    StateNotifierProvider<AchievementRiverpod, AchievementState>((ref) {
      return AchievementRiverpod();
    });

class AchievementRiverpod extends StateNotifier<AchievementState> {
  AchievementRiverpod() : super(AchievementState());

  final _achievementRepository = getIT<AchievementRepository>();

  Future<void> getAchievements(int childId) async {
    state = state.copyWith(isLoading: true, currentPage: 1, hasMore: true);
    try {
      final achievements = await _achievementRepository.getAchievements(
        childId,
        page: 1,
      );
      state = state.copyWith(
        isLoading: false,
        achievementList: achievements,
        currentPage: 2,
        hasMore: achievements.length >= 10,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMoreAchievements(int childId) async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final achievements = await _achievementRepository.getAchievements(
        childId,
        page: state.currentPage,
      );
      state = state.copyWith(
        isLoadingMore: false,
        achievementList: [...state.achievementList, ...achievements],
        currentPage: state.currentPage + 1,
        hasMore: achievements.length >= 10,
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}
