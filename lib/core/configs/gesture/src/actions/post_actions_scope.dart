// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../ref.dart';
import 'booru_actions.dart';
import 'generic_actions.dart';
import 'generic_intents.dart';

class PostActionsScope extends ConsumerWidget {
  const PostActionsScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authConfig = ref.watchConfigAuth;
    final booruBuilder = ref.watch(booruBuilderProvider(authConfig));

    final actions = <Type, Action<Intent>>{
      // Generic actions
      DownloadPostIntent: DownloadPostAction(),
      SharePostIntent: SharePostAction(),
      BookmarkPostIntent: BookmarkPostAction(),
      ViewPostTagsIntent: ViewPostTagsAction(),
      ViewPostOriginalIntent: ViewPostOriginalAction(),
      OpenPostSourceIntent: OpenPostSourceAction(),
      FavoritePostIntent: FavoritePostAction(),
      ViewPostArtistIntent: ViewPostArtistAction(),
    };

    // Add booru-specific actions if available
    if (booruBuilder != null) {
      final booruActions = booruBuilder.actionMapping();
      actions.addAll(booruActions);
    }

    return Actions(
      actions: actions,
      child: child,
    );
  }
}

extension PostActionsInvoker on WidgetRef {
  bool invokePostAction(Intent intent) {
    try {
      final result = Actions.maybeInvoke(context, intent);
      return result != null;
    } catch (e) {
      return false;
    }
  }
}
