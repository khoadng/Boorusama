import 'package:dynamic_color/dynamic_color.dart';
import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

/// Resolves a color against the active primary color when harmonization is
/// enabled, preserving the app's existing chip-color behavior.
class KurumiColorHarmonizer extends Equatable {
  const KurumiColorHarmonizer({
    required this.primaryColor,
    required this.harmonizeWithPrimary,
  });

  final Color primaryColor;
  final bool harmonizeWithPrimary;

  Color harmonize(Color color) {
    return harmonizeWithPrimary
        ? color.harmonizeWith(primaryColor)
        : primaryColor;
  }

  @override
  List<Object?> get props => [primaryColor, harmonizeWithPrimary];
}
