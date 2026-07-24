import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc_detail_formatter.dart';

export 'bloc_detail_formatter.dart';

/// ANSI color codes for terminal output.
abstract final class _Ansi {
  static const reset = '\x1B[0m';
  static const cyan = '\x1B[36m';
  static const green = '\x1B[32m';
  static const yellow = '\x1B[33m';
  static const red = '\x1B[31m';
  static const dim = '\x1B[2m';
}

/// Compact [BlocObserver] that logs one colored line per transition/change
/// instead of Talker's boxed, full-state output.
///
/// Output format (ported from diplora-clients' `DiploraBlocObserver`):
/// ```
/// ▸ ReservationsCubit • ReservationsRequested  loading → loaded
///   entries=20, statusCounts={open:1, booked:18}, propertyId=706211
/// ▸ ThemeModeCubit  system → dark
/// ✖ CmsCubit  ERROR: timeout
/// ```
class AppBlocObserver extends BlocObserver {
  /// Blocs that already fired onTransition this cycle — used to skip the
  /// redundant onChange that flutter_bloc emits for every Bloc transition.
  final _transitionedBlocs = <BlocBase<dynamic>>{};

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _transitionedBlocs.add(bloc);

    final from = BlocDetailFormatter.shortStatus(transition.currentState);
    final to = BlocDetailFormatter.shortStatus(transition.nextState);
    final event = BlocDetailFormatter.shortString(
      transition.event,
      maxLength: 40,
    );
    final eventInfo = BlocDetailFormatter.eventDetail(transition.event);
    final extra = BlocDetailFormatter.stateDetail(transition.nextState);

    _emit(
      header:
          '${_Ansi.cyan}▸${_Ansi.reset} '
          '${bloc.runtimeType} • $event  '
          '${_Ansi.dim}$from${_Ansi.reset} → '
          '${_Ansi.green}$to${_Ansi.reset}',
      eventInfo: eventInfo,
      extra: extra,
    );
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (_transitionedBlocs.remove(bloc)) return;

    final from = BlocDetailFormatter.shortStatus(change.currentState);
    final to = BlocDetailFormatter.shortStatus(change.nextState);
    final extra = BlocDetailFormatter.stateDetail(change.nextState);

    _emit(
      header:
          '${_Ansi.cyan}▸${_Ansi.reset} '
          '${bloc.runtimeType}  '
          '${_Ansi.dim}$from${_Ansi.reset} → '
          '${_Ansi.green}$to${_Ansi.reset}',
      extra: extra,
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log(
      '${_Ansi.red}✖ ${bloc.runtimeType}  ERROR: $error${_Ansi.reset}',
      name: 'bloc',
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    _transitionedBlocs.remove(bloc);
  }

  void _emit({
    required String header,
    String eventInfo = '',
    String extra = '',
  }) {
    final buffer = StringBuffer(header);
    if (eventInfo.isNotEmpty) {
      buffer.write('\n  ${_Ansi.dim}↳ $eventInfo${_Ansi.reset}');
    }
    if (extra.isNotEmpty) {
      buffer.write('\n  ${_Ansi.yellow}$extra${_Ansi.reset}');
    }
    log(buffer.toString(), name: 'bloc');
  }
}
