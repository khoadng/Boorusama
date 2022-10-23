import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';
import 'package:flutter/material.dart';

class BulkDownloadPage extends StatelessWidget {
  const BulkDownloadPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      //   shadowColor: Colors.transparent,
      //   automaticallyImplyLeading: false,
      //   title: SearchBar(enabled: false,),
      // ),
      body: SafeArea(
        child: SimpleTagSearchView(
          onSelected: (data) => print(data),
        ),
      ),
    );
  }
}
