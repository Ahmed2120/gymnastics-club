import '../dummy_data.dart';
import '../models/models/achievement_model.dart';

class AchievementRepository {
  Future<List<AchievementModel>> getAchievements(
    int childId, {
    int page = 1,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final startIndex = (page - 1) * limit;
      final achievements = achievementDummyData
          .where((e) => e['childId'] == childId)
          .skip(startIndex)
          .take(limit)
          .map<AchievementModel>((e) => AchievementModel.fromJson(e))
          .toList();

      return achievements;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
