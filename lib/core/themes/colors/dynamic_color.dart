// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

final class DynamicColorSchemes {
  const DynamicColorSchemes({
    this.light,
    this.dark,
  });

  final ColorScheme? light;
  final ColorScheme? dark;

  static const none = DynamicColorSchemes();
}

final dynamicColorSchemesProvider = Provider<DynamicColorSchemes>(
  (_) => DynamicColorSchemes.none,
  name: 'dynamicColorSchemesProvider',
);

class DynamicColorBridge extends StatelessWidget {
  const DynamicColorBridge({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KurumiDynamicColorBuilder(
      builder: (light, dark) {
        return ProviderScope(
          overrides: [
            dynamicColorSchemesProvider.overrideWithValue(
              DynamicColorSchemes(
                light: light,
                dark: dark,
              ),
            ),
          ],
          child: child,
        );
      },
    );
  }
}
