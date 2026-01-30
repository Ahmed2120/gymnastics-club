import '../../../data/models/models/achievement_model.dart';

class AchievementState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final List<AchievementModel> achievementList;
  final String error;

  AchievementState({
    this.achievementList = const [],
    this.error = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
  });

  AchievementState copyWith({
    List<AchievementModel>? achievementList,
    String? error,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
  }) {
    return AchievementState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      achievementList: achievementList ?? this.achievementList,
      error: error ?? this.error,
    );
  }
}
