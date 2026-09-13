import 'package:material_ui/material_ui.dart';

class KurumiErrorBox extends StatelessWidget {
  const KurumiErrorBox({
    required this.illustration,
    required this.errorMessage,
    required this.retryLabel,
    super.key,
    this.onRetry,
    this.altAction,
  });

  final Widget illustration;
  final String errorMessage;
  final String retryLabel;
  final VoidCallback? onRetry;
  final Widget? altAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 50),
        illustration,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Semantics(
            liveRegion: true,
            child: Text(
              errorMessage,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ?altAction,
              if (onRetry case final onRetry?)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  width: constraints.maxWidth <= 450
                      ? constraints.maxWidth
                      : null,
                  constraints: const BoxConstraints(
                    maxWidth: 450,
                  ),
                  child: FilledButton(
                    onPressed: onRetry,
                    child: Text(retryLabel),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class KurumiNoDataBox extends StatelessWidget {
  const KurumiNoDataBox({
    required this.illustration,
    required this.message,
    super.key,
  });

  final Widget illustration;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 50),
        illustration,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Semantics(
            liveRegion: true,
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
