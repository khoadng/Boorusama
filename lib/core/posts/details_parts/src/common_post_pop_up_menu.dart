// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../../../widgets/booru_popup_menu_button.dart';
import '../../post/types.dart';
import 'common_post_buttons.dart';

class CommonPostPopupMenu extends ConsumerWidget {
  const CommonPostPopupMenu({
    required this.post,
    required this.onStartSlideshow,
    required this.config,
    required this.configViewer,
    super.key,
    this.copy = true,
  });

  final Post post;
  final VoidCallback onStartSlideshow;
  final BooruConfigAuth? config;
  final BooruConfigViewer? configViewer;
  final bool copy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonPostButtonsBuilder(
      post: post,
      onStartSlideshow: onStartSlideshow,
      config: config,
      configViewer: configViewer,
      copy: copy,
      builder: (context, buttons) {
        final menuItems = <int, Widget>{};

        for (var i = 0; i < buttons.length; i++) {
          final button = buttons[i];
          menuItems[i] = Text(button.title);
        }

        return BooruPopupMenuButton<int>(
          itemBuilder: menuItems,
          onSelected: (index) {
            if (index < buttons.length) {
              buttons[index].onTap?.call();
            }
          },
        );
      },
    );
  }
}
