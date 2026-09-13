import 'package:material_ui/material_ui.dart';

/// Exact Material chip entry points exposed through Kurumi.
///
/// These aliases deliberately retain Flutter's variant-specific defaults and
/// semantics. They keep Material imports inside the design-system package
/// without collapsing chips with different interaction contracts into one
/// generic widget.
typedef KurumiMaterialChip = Chip;
typedef KurumiMaterialRawChip = RawChip;
typedef KurumiMaterialChoiceChip = ChoiceChip;
typedef KurumiMaterialFilterChip = FilterChip;
typedef KurumiMaterialActionChip = ActionChip;
