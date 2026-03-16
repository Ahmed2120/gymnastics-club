import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, int>(
  DashboardNotifier.new,
);
