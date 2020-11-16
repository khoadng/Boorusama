import 'package:boorusama/application/authentication/bloc/authentication_bloc.dart';
import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
import 'package:boorusama/application/posts/post_search/bloc/post_search_bloc.dart';
import 'package:boorusama/presentation/posts/post_download_gallery/post_download_gallery_page.dart';
import 'package:boorusama/presentation/posts/post_list/post_list_page.dart';
import 'package:boorusama/presentation/ui/bottom_bar_widget.dart';
import 'package:boorusama/presentation/posts/post_list/post_list.dart';
import 'package:boorusama/presentation/ui/drawer/side_bar.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
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
      child: SafeArea(
        child: Scaffold(
          key: controller.scaffoldKey,
          drawer: SideBarMenu(
            account: controller.account,
          ),
          resizeToAvoidBottomInset: false,
          body: _getPage(controller.currentTab, context),
          bottomNavigationBar: BottomBar(
            onTabChanged: (value) => controller.handleTabChanged(value),
          ),
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
            buildList(),
            BlocBuilder<PostSearchBloc, PostSearchState>(
              builder: (context, state) {
                return state.maybeWhen(
                  loading: () => Positioned(
                    bottom: 0,
                    child: Container(
                      height: 3,
                      width: MediaQuery.of(context).size.width,
                      child: LinearProgressIndicator(),
                    ),
                  ),
                  orElse: () => Center(),
                );
              },
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
        state.maybeWhen(
          orElse: () {},
          success: (posts, query, page) => controller.assignTagQuery(query),
          error: (error, message) {
            var flush;
            flush = Flushbar(
              icon: Icon(
                Icons.info_outline,
                color: Theme.of(context).accentColor,
              ),
              leftBarIndicatorColor: Theme.of(context).accentColor,
              title: error,
              message: message,
              mainButton: FlatButton(
                onPressed: () {
                  flush.dismiss(true);
                  controller.handleSearched("");
                },
                child: Text("OK"),
              ),
            )..show(context);
          },
        );
      },
      child: BlocListener<PostListBloc, PostListState>(
        listener: (context, state) {
          if (state is PostListLoaded) {
            if (controller.scrollController.hasClients) {
              controller.scrollController.jumpTo(0.0);
            }
            controller.posts.clear();
            controller.posts.addAll(state.posts);
          } else if (state is AddtionalPostListLoaded) {
            controller.posts.addAll(state.posts);
          } else {}
        },
        child: PostList(
          posts: controller.posts,
          onMenuTap: () => controller.scaffoldKey.currentState.openDrawer(),
          onMaxItemReached: controller.loadMorePosts,
          onSearched: (query) => controller.handleSearched(query),
          scrollThreshold: 1,
          scrollController: controller.scrollController,
        ),
      ),
    );
  }
}
