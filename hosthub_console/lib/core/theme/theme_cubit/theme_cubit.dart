import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hosthub_console/core/core.dart';

part 'theme_state.dart';

FlexScheme _resolveScheme(String? key) {
  if (key == null || key.isEmpty) {
    return FlexScheme.blue;
  }
  return FlexScheme.values.firstWhere(
    (scheme) => scheme.name == key,
    orElse: () => FlexScheme.blue,
  );
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
    : super(ThemeState(scheme: _resolveScheme(AppConfig.current.themeScheme)));

  void setState(FlexScheme scheme) => emit(ThemeState(scheme: scheme));

  void resetToDefault() =>
      setState(_resolveScheme(AppConfig.current.themeScheme));
}
