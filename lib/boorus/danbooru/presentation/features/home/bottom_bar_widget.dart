// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            backgroundColor: Theme.of(context).accentIconTheme.color,
            icon: FaIcon(
              FontAwesomeIcons.home,
              color: Colors.black,
            ),
            activeIcon: FaIcon(
              FontAwesomeIcons.home,
              color: Theme.of(context).accentColor,
            ),
            title: Text(
              "Home",
              style: TextStyle(color: Theme.of(context).accentColor),
            )),
        BubbleBottomBarItem(
            backgroundColor: Theme.of(context).accentIconTheme.color,
            icon: FaIcon(
              Icons.explore,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.explore,
              color: Theme.of(context).accentColor,
            ),
            title: Text(
              "Explore",
              style: TextStyle(color: Theme.of(context).accentColor),
            )),
        BubbleBottomBarItem(
            backgroundColor: Theme.of(context).accentIconTheme.color,
            icon: FaIcon(
              FontAwesomeIcons.solidHeart,
              color: Colors.black,
            ),
            activeIcon: FaIcon(
              FontAwesomeIcons.solidHeart,
              color: Theme.of(context).accentColor,
            ),
            title: Text(
              "Favorites",
              style: TextStyle(color: Theme.of(context).accentColor),
            )),
      ],
    );
  }
}
