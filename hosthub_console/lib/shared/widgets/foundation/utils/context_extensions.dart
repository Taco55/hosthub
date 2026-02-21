import 'package:flutter/material.dart';
import 'package:hosthub_console/shared/l10n/l10n.dart';

extension BuildContextX on BuildContext {
  S get l10n => S.of(this);
  S get s => S.of(this);
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
}
