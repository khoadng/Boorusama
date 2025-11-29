// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:multi_split_view/multi_split_view.dart';

class TagEditViewController extends ChangeNotifier {
  TagEditViewController();

  final splitController = MultiSplitViewController(
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
        size: MediaQuery.heightOf(context) * 0.5,
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
