import 'package:boorusama/application/authentication/bloc/authentication_bloc.dart';
import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/application/posts/post_search/bloc/post_search_bloc.dart';
import 'package:boorusama/presentation/posts/post_download_gallery/post_download_gallery_page.dart';
import 'package:boorusama/presentation/posts/post_list/post_list_page.dart';
import 'package:boorusama/presentation/ui/bottom_bar_widget.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_list_widget.dart';
import 'package:boorusama/presentation/posts/post_list/widgets/post_search_widget.dart';
import 'package:boorusama/presentation/ui/drawer/side_bar.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:widget_view/widget_view.dart';

class PostListPageView
    extends StatefulWidgetView<PostListPage, PostListPageState> {
  PostListPageView(PostListPageState controller, {Key key})
      : super(controller, key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is Authenticated) {
          controller.assignAccount(state.account);
        } else if (state is Unauthenticated) {
          controller.removeAccount(state.account);
        }
      },
      child: Scaffold(
        drawer: SideBarMenu(
          account: controller.account,
        ),
        resizeToAvoidBottomInset: false,
        body: _getPage(controller.currentTab, context),
        bottomNavigationBar: BottomBar(
          onTabChanged: (value) => controller.handleTabChanged(value),
        ),
      ),
    );
  }

  //TODO: refactor
  Widget _getPage(int tabIndex, BuildContext context) {
    switch (tabIndex) {
      case 0:
        return Stack(
          fit: StackFit.expand,
          children: [
            BlocBuilder<PostSearchBloc, PostSearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return Positioned(
                    bottom: 0,
                    child: Container(
                      height: 3,
                      width: MediaQuery.of(context).size.width,
                      child: LinearProgressIndicator(),
                    ),
                  );
                } else {
                  return Center();
                }
              },
            ),
            PostListSearchBar(
              controller: controller.searchBarController,
              onSearched: controller.handleSearched,
              body: FloatingSearchBarScrollNotifier(child: buildList()),
              onDownloadAllSelected: controller.downloadAllPosts,
            ),
          ],
        );
      case 1:
        return PostDownloadGalleryPage();
    }
  }

  Widget buildList() {
    return BlocListener<PostSearchBloc, PostSearchState>(
      listener: (context, state) {
        if (state is SearchError) {
          var flush;
          flush = Flushbar(
            icon: Icon(
              Icons.info_outline,
              color: ThemeData.dark().accentColor,
            ),
            leftBarIndicatorColor: ThemeData.dark().accentColor,
            title: state.error,
            message: state.message,
            mainButton: FlatButton(
              onPressed: () {
                flush.dismiss(true);
                controller.handleSearched("");
              },
              child: Text("OK"),
            ),
          )..show(context);
        } else if (state is SearchSuccess) {
          controller.assignTagQuery(state.query);
        } else {
          //TODO: handle other cases
        }
      },
      child: BlocConsumer<PostListBloc, PostListState>(
        listener: (context, state) {
          if (state is PostListLoaded) {
            controller.posts.clear();
            controller.posts.addAll(state.posts);
          } else if (state is AddtionalPostListLoaded) {
            controller.posts.addAll(state.posts);
          } else {}
        },
        builder: (context, state) {
          if (state is PostListLoaded || state is AddtionalPostListLoaded) {
            return buildListWithData();
          } else if (state is PostListError) {
            // return Lottie.asset(
            //     "assets/animations/11116-404-planet-animation.json");
          } else {
            return Center(child: Text("Nothing's here"));
          }
        },
      ),
    );
  }

  Widget buildListWithData() {
    return PostList(
      posts: controller.posts,
      onMaxItemReached: controller.loadMorePosts,
      scrollThreshold: 1,
      scrollController: controller.scrollController,
    );
  }

  Widget buildError() {
    return Center(
      child: Text("OOPS something went wrong"),
    );
  }
}
