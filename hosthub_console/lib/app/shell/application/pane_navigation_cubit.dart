import 'package:flutter_bloc/flutter_bloc.dart';

import 'right_pane_route.dart';

/// Generic navigation state for tabbed, two-pane admin screens.
class PaneNavigationState {
  const PaneNavigationState({
    this.currentTabIndex = 0,
    this.rightPaneStack = const <RightPaneRoute>[],
  });

  /// Index of the currently selected tab (for segmented controls).
  final int currentTabIndex;

  /// Stack of routes to display in the right-hand pane.
  final List<RightPaneRoute> rightPaneStack;

  RightPaneRoute? get topRoute =>
      rightPaneStack.isEmpty ? null : rightPaneStack.last;

  bool get canPopRightPane => rightPaneStack.length > 1;

  PaneNavigationState copyWith({
    int? currentTabIndex,
    List<RightPaneRoute>? rightPaneStack,
  }) {
    return PaneNavigationState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      rightPaneStack: rightPaneStack ?? this.rightPaneStack,
    );
  }
}

/// Simple cubit to coordinate tab selection and pane navigation.
class PaneNavigationCubit extends Cubit<PaneNavigationState> {
  PaneNavigationCubit() : super(const PaneNavigationState());

  /// Select a tab by index.
  void selectTab(int index) {
    emit(state.copyWith(currentTabIndex: index));
  }

  /// Open the detail pane with the provided root route.
  void openRightPane(RightPaneRoute root) {
    emit(state.copyWith(rightPaneStack: [root]));
  }

  /// Push a route onto the right pane stack.
  void pushRightPane(RightPaneRoute route) {
    final nextStack = state.rightPaneStack.isEmpty
        ? <RightPaneRoute>[route]
        : [...state.rightPaneStack, route];
    emit(state.copyWith(rightPaneStack: nextStack));
  }

  /// Pop the top-most route, or close the pane if only one remains.
  void popRightPane() {
    if (state.rightPaneStack.length > 1) {
      final nextStack = [...state.rightPaneStack]..removeLast();
      emit(state.copyWith(rightPaneStack: nextStack));
      return;
    }
    closeRightPane();
  }

  /// Close the detail pane and clear the stack.
  void closeRightPane() {
    emit(state.copyWith(rightPaneStack: const <RightPaneRoute>[]));
  }
}
