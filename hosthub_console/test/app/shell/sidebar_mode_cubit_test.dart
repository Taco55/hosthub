import 'package:flutter_test/flutter_test.dart';
import 'package:styled_widgets/styled_widgets.dart';

import 'package:hosthub_console/app/shell/application/sidebar_mode_cubit.dart';

void main() {
  test('starts expanded; setMode and toggle switch between rail modes', () {
    final cubit = SidebarModeCubit();
    expect(cubit.state, StyledSideMenuMode.expanded);

    cubit.toggle();
    expect(cubit.state, StyledSideMenuMode.compact);

    cubit.toggle();
    expect(cubit.state, StyledSideMenuMode.expanded);

    cubit.setMode(StyledSideMenuMode.compact);
    expect(cubit.state, StyledSideMenuMode.compact);
    cubit.close();
  });
}
