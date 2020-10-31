import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key key, @required this.onTabChanged}) : super(key: key);

  final ValueChanged<int> onTabChanged;

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int currentIndex;

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
    return BubbleBottomBar(
      opacity: .2,
      backgroundColor: ThemeData.dark().bottomAppBarColor,
      currentIndex: currentIndex,
      onTap: changePage,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      elevation: 8,
      fabLocation: BubbleBottomBarFabLocation.end, //new
      hasNotch: true, //new
      hasInk: true, //new, gives a cute ink effect
      inkColor: Colors.black12, //optional, uses theme color if not specified
      items: <BubbleBottomBarItem>[
        BubbleBottomBarItem(
            backgroundColor: ThemeData.dark().accentIconTheme.color,
            icon: Icon(
              Icons.dashboard,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.dashboard,
              color: ThemeData.dark().accentColor,
            ),
            title: Text(
              "Posts",
              style: TextStyle(color: ThemeData.dark().textSelectionColor),
            )),
        BubbleBottomBarItem(
            backgroundColor: Colors.indigo,
            icon: Icon(
              Icons.folder_open,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.folder_open,
              color: ThemeData.dark().accentColor,
            ),
            title: Text(
              "Folders",
              style: TextStyle(color: ThemeData.dark().textSelectionColor),
            )),
        BubbleBottomBarItem(
            backgroundColor: Colors.green,
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.menu,
              color: ThemeData.dark().accentColor,
            ),
            title: Text(
              "Menu",
              style: TextStyle(color: ThemeData.dark().textSelectionColor),
            )),
      ],
    );
  }
}
