// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void initializeRuntimeErrorWidget() {
  ErrorWidget.builder = buildRuntimeErrorWidget;
}

@visibleForTesting
Widget buildRuntimeErrorWidget(FlutterErrorDetails details) {
  return _RuntimeErrorWidget(details: details);
}

class _RuntimeErrorWidget extends StatelessWidget {
  const _RuntimeErrorWidget({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFF121212),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFFFB4AB),
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This section could not be displayed. Please retry the action or restart the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFCAC4D0), fontSize: 14),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    Text(
                      details.exceptionAsString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFFB4AB),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
