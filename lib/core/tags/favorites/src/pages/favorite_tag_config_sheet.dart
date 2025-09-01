// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../types/favorite_tags_sort_type.dart';

class FavoriteTagConfigSheet extends StatelessWidget {
  const FavoriteTagConfigSheet({
    required this.onSorted,
    super.key,
  });

  final void Function(FavoriteTagsSortType) onSorted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DragLine(),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  context.t.sort.sort_by,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  context.t.sort.recently_added,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSorted(FavoriteTagsSortType.recentlyAdded);
                },
              ),
              ListTile(
                title: Text(
                  context.t.sort.recently_updated,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSorted(FavoriteTagsSortType.recentlyUpdated);
                },
              ),
              ListTile(
                title: Text(
                  context.t.sort.name_asc,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSorted(FavoriteTagsSortType.nameAZ);
                },
              ),
              ListTile(
                title: Text(
                  context.t.sort.name_desc,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSorted(FavoriteTagsSortType.nameZA);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}
