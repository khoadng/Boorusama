// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key key, @required this.onTabChanged}) : super(key: key);

  final ValueChanged<int> onTabChanged;

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int currentIndex;

  final buttonIcons = [
    FontAwesomeIcons.home,
    Icons.explore,
    // FontAwesomeIcons.solidHeart,
  ];

  final labels = [
    "Home",
    "Explore",
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
    return Material(
      color: Colors.transparent,
      elevation: 20,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).bottomAppBarTheme.color,
          boxShadow: [
            BoxShadow(
              blurRadius: 1.0,
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          selectedFontSize: 0,
          backgroundColor: Colors.transparent,
          elevation: 20,
          currentIndex: currentIndex,
          onTap: (value) => changePage(value),
          items: [
            ...buttonIcons
                .map(
                  (icon) => BottomNavigationBarItem(
                    label: "",
                    icon: SizedBox(
                      height: kBottomNavigationBarHeight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(icon),
                          Text(
                            labels[buttonIcons.indexOf(icon)],
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: currentIndex == buttonIcons.indexOf(icon)
                                    ? Theme.of(context).accentColor
                                    : Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ),
                )
                .toList()
          ],
        ),
      ),
    );
  }
}
