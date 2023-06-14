// Flutter imports:
import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  const SideBar({
    super.key,
    required this.content,
    this.servers,
    this.width,
  });

  final List<Widget>? servers;
  final Widget content;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (servers != null && servers!.isNotEmpty)
          ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              child: Column(
                children: servers!,
              ),
            ),
          ),
        Container(
          color: Theme.of(context).colorScheme.background,
          constraints: BoxConstraints.expand(width: width ?? 230),
          child: content,
        ),
      ],
    );
  }
}
