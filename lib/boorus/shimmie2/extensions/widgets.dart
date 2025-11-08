// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/widgets/settings_card.dart';
import 'types.dart';

class ExtensionCategorySection extends StatelessWidget {
  const ExtensionCategorySection({
    super.key,
    required this.category,
    required this.extensions,
  });

  final String category;
  final List<Extension> extensions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SettingsCard(
        title: category,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: extensions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final ext = extensions[index];
            return _ExtensionTile(extension: ext);
          },
        ),
      ),
    );
  }
}

class _ExtensionTile extends StatelessWidget {
  const _ExtensionTile({
    required this.extension,
  });

  final Extension extension;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(
        extension.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: extension.description.isNotEmpty
          ? Text(extension.description)
          : null,
    );
  }
}

class ExtensionRefreshButton extends StatefulWidget {
  const ExtensionRefreshButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  State<ExtensionRefreshButton> createState() => _ExtensionRefreshButtonState();
}

class _ExtensionRefreshButtonState extends State<ExtensionRefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isLoading) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(ExtensionRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
      _rotationController.reset();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: RotationTransition(
        turns: _rotationController,
        child: const Icon(Icons.refresh),
      ),
      onPressed: widget.isLoading ? null : widget.onPressed,
    );
  }
}
