import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymnastics_club/core/services/init_getit.dart';
import '../../auth/auth_provider.dart';
import '../../../data/repositories/child_repository.dart';
import 'child_state.dart';
import '../../../core/errors/error_handler.dart';

final childRiverpod = StateNotifierProvider<ChildRiverpod, ChildState>((ref) {
  return ChildRiverpod(ref);
});

class ChildRiverpod extends StateNotifier<ChildState> {
  final Ref ref;
  ChildRiverpod(this.ref) : super(ChildState());

  final _childRepository = getIT<ChildRepository>();

  Future<void> getChildren() async {
    state = state.copyWith(isLoading: true);
    try {
      final phone = ref.read(authProvider).phoneNumber;
      final children = await _childRepository.getChildren(phone: phone);
      state = state.copyWith(
        isLoading: false,
        childrenList: children,
        selectedChild:
            state.selectedChild ??
            (children.isNotEmpty ? children.first : null),
        error: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: AppErrorHandler.handle(e));
    }
  }

  void selectChild(int id) {
    final child = state.childrenList.firstWhere((element) => element.id == id);
    state = state.copyWith(selectedChild: child);
  }
}
