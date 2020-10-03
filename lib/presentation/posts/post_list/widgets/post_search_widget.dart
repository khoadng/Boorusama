import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class PostListSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearched;
  final FloatingSearchBarController controller;
  // final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

  PostListSearchBar({Key key, @required this.onSearched, this.controller});

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      hint: 'Search...',
      controller: controller,
      onSubmitted: _handleSubmitted,
      clearQueryOnClose: false,
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: true,
        ),
      ],
      builder: (context, transition) => buildExpandableBody(),
    );
  }

  Widget buildExpandableBody() {
    return Material(
      color: Colors.white,
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
    );
  }

  void _handleSubmitted(String value) {
    onSearched(value);
    controller.close();
  }
}
