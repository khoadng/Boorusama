import 'package:flutter/material.dart';

class PostInputField extends StatelessWidget {
  final ValueChanged<String> onSearched;

  PostInputField({Key key, @required this.onSearched});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: TextField(
        onSubmitted: _handleSubmitted,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Search",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  void _handleSubmitted(String value) {
    onSearched(value);
  }
}
