// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';

// Project imports:

class PoolImage extends StatelessWidget {
  const PoolImage({
    super.key,
    required this.pool,
  });

  final PoolItem pool;

  @override
  Widget build(BuildContext context) {
    return (pool.coverUrl != null)
        ? CachedNetworkImage(
            httpHeaders: {
              'User-Agent': context.read<UserAgentGenerator>().generate(),
            },
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            imageUrl: pool.coverUrl!,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            child: Center(
              child: const Text('pool.mature_banned_content').tr(),
            ),
          );
  }
}
