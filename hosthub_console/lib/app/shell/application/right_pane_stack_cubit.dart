import 'package:flutter_bloc/flutter_bloc.dart';

import 'right_pane_route.dart';

class RightPaneStackState {
  const RightPaneStackState({this.stack = const <RightPaneRoute>[]});

  final List<RightPaneRoute> stack;

  bool get isOpen => stack.isNotEmpty;

  RightPaneRoute? get topRoute => isOpen ? stack.last : null;

  bool get canPop => stack.length > 1;

  RightPaneStackState copyWith({List<RightPaneRoute>? stack}) {
    return RightPaneStackState(stack: stack ?? this.stack);
  }
}

class RightPaneStackCubit extends Cubit<RightPaneStackState> {
  RightPaneStackCubit() : super(const RightPaneStackState());

  void openRightPane(RightPaneRoute root) {
    emit(RightPaneStackState(stack: [root]));
  }

  void closeRightPane() {
    emit(const RightPaneStackState());
  }

  void pushRightPane(RightPaneRoute route) {
    final nextStack = [...state.stack, route];
    emit(state.copyWith(stack: nextStack));
  }

  void popRightPane() {
    if (state.stack.length > 1) {
      final nextStack = [...state.stack]..removeLast();
      emit(state.copyWith(stack: nextStack));
      return;
    }
    closeRightPane();
  }
}
