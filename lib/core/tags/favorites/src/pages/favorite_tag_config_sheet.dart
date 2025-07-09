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
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Recently added'.hc,
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
                  'Recently updated'.hc,
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
                  'Name (A-Z)'.hc,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSorted(FavoriteTagsSortType.nameAZ);
                },
              ),
              // name (z-a)
              ListTile(
                title: Text(
                  'Name (Z-A)'.hc,
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
