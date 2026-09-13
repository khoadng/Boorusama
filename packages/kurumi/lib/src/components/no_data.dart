import 'package:material_ui/material_ui.dart';

class KurumiGenericNoDataBox extends StatelessWidget {
  const KurumiGenericNoDataBox({
    required this.text,
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Center(
          child: Semantics(
            liveRegion: true,
            label: text,
            excludeSemantics: true,
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ),
    );
  }
}
