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
      backgroundColor: Theme.of(context).bottomAppBarTheme.color,
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
            backgroundColor: Theme.of(context).bottomAppBarTheme.color,
            icon: Icon(
              Icons.dashboard,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.dashboard,
              color: Theme.of(context).accentColor,
            ),
            title: Text(
              "Posts",
              style: TextStyle(color: Theme.of(context).accentColor),
            )),
        BubbleBottomBarItem(
            backgroundColor: Theme.of(context).accentIconTheme.color,
            icon: Icon(
              Icons.folder_open,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.folder_open,
              color: Theme.of(context).accentColor,
            ),
            title: Text(
              "Folders",
              style: TextStyle(color: Theme.of(context).accentColor),
            )),
        BubbleBottomBarItem(
            backgroundColor: Theme.of(context).accentIconTheme.color,
            icon: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.menu,
              color: Theme.of(context).accentColor,
            ),
            title: Text(
              "Menu",
              style: TextStyle(color: Theme.of(context).accentColor),
            )),
      ],
    );
  }
}
