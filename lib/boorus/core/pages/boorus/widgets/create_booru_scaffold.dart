// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/booru.dart';
import 'package:boorusama/flutter.dart';
import 'selected_booru_chip.dart';

class CreateBooruScaffold extends StatelessWidget {
  const CreateBooruScaffold({
    super.key,
    required this.booru,
    required this.children,
  });

  final List<Widget> children;
  final Booru booru;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.focusScope.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          title: SelectedBooruChip(
            booru: booru,
          ),
          actions: [
            IconButton(
              onPressed: context.navigator.pop,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}
