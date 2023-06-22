// Flutter imports:
import 'package:flutter/material.dart';

class BooruBottomBar extends StatefulWidget {
  const BooruBottomBar({
    super.key,
    required this.onTabChanged,
    this.initialValue = 0,
    required this.items,
  });

  final ValueChanged<int> onTabChanged;
  final int initialValue;
  final List<BottomNavigationBarItem> Function(int currentIndex) items;

  @override
  State<BooruBottomBar> createState() => _BooruBottomBarState();
}

class _BooruBottomBarState extends State<BooruBottomBar> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialValue;
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
    widget.onTabChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      items: widget.items(currentIndex),
      currentIndex: currentIndex,
      onTap: changePage,
    );
  }
}
