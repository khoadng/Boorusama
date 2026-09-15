// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/foundation/boot/runtime_error_widget.dart';

void main() {
  testWidgets('replaces the default grey error widget with an explanation', (
    tester,
  ) async {
    final details = FlutterErrorDetails(
      exception: StateError('provider initialization failed'),
    );
    final previousBuilder = ErrorWidget.builder;
    initializeRuntimeErrorWidget();
    final installedErrorWidget = ErrorWidget.builder(details);
    ErrorWidget.builder = previousBuilder;

    await tester.pumpWidget(
      SizedBox(
        width: 800,
        height: 600,
        child: installedErrorWidget,
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text(
        'This section could not be displayed. Please retry the action or restart the app.',
      ),
      findsOneWidget,
    );
    expect(find.byType(ColoredBox), findsWidgets);
  });
}
