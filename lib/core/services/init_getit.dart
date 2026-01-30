import 'package:get_it/get_it.dart';

import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/news_repository.dart';
import '../../data/repositories/permission_repository.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/child_repository.dart';

GetIt getIT = GetIt.instance;

void setupLocator() {
  getIT.registerLazySingleton<NewsRepositories>(() => NewsRepositories());
  getIT.registerLazySingleton<AttendanceRepository>(() => AttendanceRepository());

  getIT.registerLazySingleton<PermissionRepository>(
    () => PermissionRepository(),
  );

  getIT.registerLazySingleton<AchievementRepository>(
    () => AchievementRepository(),
  );
  getIT.registerLazySingleton<ScheduleRepository>(() => ScheduleRepository());
  getIT.registerLazySingleton<ChildRepository>(() => ChildRepository());
}
