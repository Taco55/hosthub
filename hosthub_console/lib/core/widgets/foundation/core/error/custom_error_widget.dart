import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hosthub_console/core/l10n/l10n.dart';

bool _flutterErrorHandlerInstalled = false;

void setupErrorWidget() {
  if (!_flutterErrorHandlerInstalled) {
    FlutterErrorDetails sanitizeDetails(FlutterErrorDetails original) {
      final collector = original.informationCollector;
      if (collector == null) return original;

      Iterable<DiagnosticsNode> sanitizedCollector() {
        try {
          final Iterable<dynamic> nodes = collector();
          final sanitized = <DiagnosticsNode>[];
          for (final node in nodes) {
            if (node is DiagnosticsNode) {
              sanitized.add(node);
            } else {
              debugPrint(
                '[FlutterError] Dropped diagnostics entry of type ${node.runtimeType}',
              );
            }
          }
          return sanitized;
        } catch (err, stack) {
          debugPrint('[FlutterError] informationCollector threw: $err');
          debugPrintStack(stackTrace: stack);
          return const <DiagnosticsNode>[];
        }
      }

      return FlutterErrorDetails(
        exception: original.exception,
        stack: original.stack,
        library: original.library,
        context: original.context,
        informationCollector: sanitizedCollector,
        silent: original.silent,
      );
    }

    final originalOnError = FlutterError.onError ?? FlutterError.presentError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final safeDetails = sanitizeDetails(details);
      final message = safeDetails.exceptionAsString();
      // Flutter Web can throw frames at disposed views during fast redirects
      // or lifecycle transitions; ignore the noisy assertion in that case.
      if (kIsWeb &&
          (message.contains('disposed EngineFlutterView') ||
              (message.contains('window.dart:99') &&
                  message.contains('!isDisposed')))) {
        return;
      }

      try {
        originalOnError(safeDetails);
      } catch (error, stackTrace) {
        debugPrint(
          'Flutter error reporting failed ($error). Falling back to simple logging.',
        );
        debugPrint('Original exception: ${safeDetails.exception}');
        if (safeDetails.stack != null) {
          debugPrint('${safeDetails.stack}');
        }
        debugPrint('Reporter stack: $stackTrace');
      }
    };
    _flutterErrorHandlerInstalled = true;
  }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              S.current.oopsAproblemOccured,
              style: const TextStyle(color: Color(0xFF2B088E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              details.exception.toString(),
              style: const TextStyle(color: Color(0xFF2B088E)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  };
}
