// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/widgets/widgets.dart';
import 'favorite_tags_page.dart';

class FavoriteTagConfigSheet extends StatelessWidget {
  const FavoriteTagConfigSheet({
    super.key,
    required this.onSorted,
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
                title: const Text(
                  'Recently added',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSorted(FavoriteTagsSortType.recentlyAdded);
                },
              ),
              ListTile(
                title: const Text(
                  'Recently updated',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSorted(FavoriteTagsSortType.recentlyUpdated);
                },
              ),
              ListTile(
                title: const Text(
                  'Name (A-Z)',
                  style: TextStyle(
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
                title: const Text(
                  'Name (Z-A)',
                  style: TextStyle(
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
