import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:styled_widgets/styled_widgets.dart';

/// Pinned width mode of the desktop navigation rail (compact icon rail vs the
/// full expanded menu), toggled by the pin/collapse button in the rail header.
/// Reuses the shared [StyledSideMenuMode] so the shell, the rail and the
/// library widget speak the same enum.
class SidebarModeCubit extends Cubit<StyledSideMenuMode> {
  SidebarModeCubit() : super(StyledSideMenuMode.expanded);

  void setMode(StyledSideMenuMode mode) => emit(mode);

  void toggle() => emit(
        state == StyledSideMenuMode.expanded
            ? StyledSideMenuMode.compact
            : StyledSideMenuMode.expanded,
      );
}
