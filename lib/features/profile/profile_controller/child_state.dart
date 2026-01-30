import '../../../data/models/models/child_model.dart';

class ChildState {
  final bool isLoading;
  final List<ChildModel> childrenList;
  final ChildModel? selectedChild;
  final String error;

  ChildState({
    this.childrenList = const [],
    this.selectedChild,
    this.error = '',
    this.isLoading = false,
  });

  ChildState copyWith({
    List<ChildModel>? childrenList,
    ChildModel? selectedChild,
    String? error,
    bool? isLoading,
  }) {
    return ChildState(
      isLoading: isLoading ?? this.isLoading,
      childrenList: childrenList ?? this.childrenList,
      selectedChild: selectedChild ?? this.selectedChild,
      error: error ?? this.error,
    );
  }
}
