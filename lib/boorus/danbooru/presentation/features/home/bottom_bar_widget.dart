// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key, required this.onTabChanged}) : super(key: key);

  final ValueChanged<int> onTabChanged;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late int currentIndex;

  final labels = [
    'Home',
    'Explore',
    'Pool',
    // "Favorites",
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
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
      showUnselectedLabels: false,
      showSelectedLabels: false,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      items: const [
        BottomNavigationBarItem(
          label: 'Home',
          icon: FaIcon(
            FontAwesomeIcons.house,
            size: 20,
          ),
        ),
        BottomNavigationBarItem(
          label: 'Explore',
          icon: FaIcon(
            Icons.explore,
            size: 20,
          ),
        ),
        BottomNavigationBarItem(
          label: 'Pool',
          icon: FaIcon(
            FontAwesomeIcons.images,
            size: 20,
          ),
        ),
      ],
      currentIndex: currentIndex,
      onTap: changePage,
    );
  }
}
