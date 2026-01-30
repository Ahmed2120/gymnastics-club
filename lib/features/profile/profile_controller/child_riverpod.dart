import 'package:flutter_riverpod/legacy.dart';
import 'package:gymnastics_club/core/services/init_getit.dart';
import '../../../data/repositories/child_repository.dart';
import 'child_state.dart';

final childRiverpod = StateNotifierProvider<ChildRiverpod, ChildState>((ref) {
  return ChildRiverpod();
});

class ChildRiverpod extends StateNotifier<ChildState> {
  ChildRiverpod() : super(ChildState());

  final _childRepository = getIT<ChildRepository>();

  Future<void> getChildren() async {
    state = state.copyWith(isLoading: true);
    try {
      final children = await _childRepository.getChildren();
      state = state.copyWith(
        isLoading: false,
        childrenList: children,
        selectedChild:
            state.selectedChild ??
            (children.isNotEmpty ? children.first : null),
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectChild(int id) {
    final child = state.childrenList.firstWhere((element) => element.id == id);
    state = state.copyWith(selectedChild: child);
  }
}
