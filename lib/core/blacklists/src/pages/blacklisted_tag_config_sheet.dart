// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import '../types/blacklisted_tags_sort_type.dart';

class BlacklistedTagConfigSheet extends StatelessWidget {
  const BlacklistedTagConfigSheet({
    required this.onSorted,
    super.key,
  });

  final void Function(BlacklistedTagsSortType) onSorted;

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
                  onSorted(BlacklistedTagsSortType.recentlyAdded);
                },
              ),
              // ListTile(
              //   title: const Text(
              //     'Recently updated',
              //     style: TextStyle(
              //       fontSize: 16,
              //     ),
              //   ),
              //   onTap: () {
              //     Navigator.pop(context);
              //     onSorted(BlacklistedTagsSortType.recentlyUpdated);
              //   },
              // ),
              ListTile(
                title: const Text(
                  'Name (A-Z)',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onSorted(BlacklistedTagsSortType.nameAZ);
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
                  onSorted(BlacklistedTagsSortType.nameZA);
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
