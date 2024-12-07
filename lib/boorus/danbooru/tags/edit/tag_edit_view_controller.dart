// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:multi_split_view/multi_split_view.dart';

// Project imports:
import 'package:boorusama/flutter.dart';

class TagEditViewController extends ChangeNotifier {
  TagEditViewController();

  final MultiSplitViewController splitController = MultiSplitViewController(
    areas: [
      Area(
        id: 'image',
        data: 'image',
        size: 250,
        min: 25,
      ),
      Area(
        id: 'content',
        data: 'content',
      ),
    ],
  );

  void setDefaultSplit() {
    splitController.areas = [
      Area(
        id: 'image',
        data: 'image',
        size: 250,
        min: 25,
      ),
      Area(
        id: 'content',
        data: 'content',
      ),
    ];

    notifyListeners();
  }

  void setMaxSplit(BuildContext context) {
    splitController.areas = [
      Area(
        id: 'image',
        data: 'image',
        size: context.screenHeight * 0.5,
        min: 50 + MediaQuery.viewPaddingOf(context).top,
      ),
      Area(
        id: 'content',
        data: 'content',
      ),
    ];

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    splitController.dispose();
  }
}
