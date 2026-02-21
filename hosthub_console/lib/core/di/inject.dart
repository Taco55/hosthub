// ignore_for_file: unintended_html_in_doc_comment

import 'package:get_it/get_it.dart';

final GetIt _getIt = GetIt.instance;

/// Global dependency injector (short alias: I)
/// Use I<T>() to retrieve registered services
/// Use I.registerSingleton<T>(...) to register instances
class I {
  /// Retrieves a registered instance of type T
  static T call<T extends Object>() => _getIt<T>();

  /// Alternative syntax: I.get<T>() is equivalent to I<T>()
  static T get<T extends Object>() => _getIt<T>();

  /// Registers a singleton instance of type T
  static void registerSingleton<T extends Object>(
    T instance, {
    bool signalsReady = false,
    void Function(T)? dispose,
  }) {
    _getIt.registerSingleton<T>(
      instance,
      signalsReady: signalsReady,
      dispose: dispose,
    );
  }

  /// Resets the entire GetIt container (used in tests or full teardown)
  static Future<void> reset() => _getIt.reset();

  /// Checks if a type T is already registered
  static bool isRegistered<T extends Object>() => _getIt.isRegistered<T>();
}
