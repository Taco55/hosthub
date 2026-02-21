import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  static const _maxLogLength = 200;

  void _log(String message) {
    log('[AppBlocObserver] $message');
  }

  String _truncate(Object? value) {
    final text = value?.toString() ?? 'null';
    if (text.length <= _maxLogLength) return text;
    return '${text.substring(0, _maxLogLength)}…';
  }

  String _describeState(Object? state) {
    if (state == null) return 'null';
    try {
      // Most states expose a status field; logging only that keeps output readable.
      final status = (state as dynamic).status;
      return '${state.runtimeType}(status: $status)';
    } catch (_) {
      return _truncate('${state.runtimeType}: ${state.toString()}');
    }
  }

  String _describeValue(Object? value) {
    if (value == null) return 'null';
    return _truncate('${value.runtimeType}: $value');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _log('onEvent(${bloc.runtimeType}, ${_describeValue(event)})');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _log(
      'onChange(${bloc.runtimeType}, '
      '${_describeState(change.currentState)} -> ${_describeState(change.nextState)})',
    );
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _log(
      'onTransition(${bloc.runtimeType}, '
      '${_describeValue(transition.event)}, '
      '${_describeState(transition.currentState)} -> ${_describeState(transition.nextState)})',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}
