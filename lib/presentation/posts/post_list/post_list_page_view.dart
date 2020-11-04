import 'package:boorusama/application/accounts/add_account/bloc/add_account_bloc.dart';
import 'package:boorusama/application/accounts/get_all_accounts/bloc/get_all_accounts_bloc.dart';
import 'package:boorusama/application/accounts/remove_account/bloc/remove_account_bloc.dart';
import 'package:boorusama/application/posts/post_list/bloc/post_list_bloc.dart';
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
import 'package:widget_view/widget_view.dart';

class PostListPageView
    extends StatefulWidgetView<PostListPage, PostListPageState> {
  PostListPageView(PostListPageState controller, {Key key})
      : super(controller, key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: workaround, this event is not working in MultiBlocListener somehow
    return BlocListener<RemoveAccountBloc, RemoveAccountState>(
      listener: (context, state) {
        if (state is RemoveAccountSuccess) {
          controller.removeAccount(state.account);
        }
      },
      child: BlocListener<AddAccountBloc, AddAccountState>(
        listener: (context, state) {
          if (state is AddAccountDone) {
            controller.assignAccount(state.account);
          }
        },
        child: BlocListener<GetAllAccountsBloc, GetAllAccountsState>(
          listener: (context, state) {
            if (state is GetAllAccountsSuccess) {
              controller.assignAccount(state.accounts.first);
            }
          },
          child: Scaffold(
            drawer: SideBarMenu(
              account: controller.account,
            ),
            resizeToAvoidBottomInset: false,
            body: _getPage(controller.currentTab),
            bottomNavigationBar: BottomBar(
              onTabChanged: (value) => controller.handleTabChanged(value),
            ),
          ),
        ),
      ),
    );
  }

  //TODO: refactor
  Widget _getPage(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return Stack(fit: StackFit.expand, children: [
          buildList(),
          PostListSearchBar(
            controller: controller.searchBarController,
            onSearched: controller.handleSearched,
            onDownloadAllSelected: controller.downloadAllPosts,
          ),
        ]);
      case 1:
        return PostDownloadGalleryPage();
    }
  }

  Widget buildList() {
    return BlocConsumer<PostListBloc, PostListState>(
      listener: (context, state) {
        if (state is PostListLoaded) {
          controller.posts.clear();
          controller.posts.addAll(state.posts);
        } else if (state is AddtionalPostListLoaded) {
          controller.posts.addAll(state.posts);
          //TODO: warning internal state exposed
          controller.isBusy = false;
        } else if (state is PostListError) {
          Flushbar(
            icon: Icon(
              Icons.info_outline,
              color: ThemeData.dark().accentColor,
            ),
            leftBarIndicatorColor: ThemeData.dark().accentColor,
            title: "Hold up!",
            message: state.message,
            duration: Duration(seconds: 6),
          )..show(context);
        } else {
          //TODO: handle other cases
        }
      },
      builder: (context, state) {
        if (state is PostListInitial) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is PostListLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is PostListLoaded ||
            state is AddtionalPostListLoaded ||
            state is AdditionalPostListLoading) {
          return buildListWithData();
        } else if (state is PostListError) {
          return Lottie.asset(
              "assets/animations/11116-404-planet-animation.json");
        } else {
          return Center(child: Text("Nothing's here"));
        }
      },
    );
  }

  Widget buildListWithData() {
    return PostList(
      posts: controller.posts,
      onScrollDirectionChanged: (value) => value == ScrollDirection.forward
          ? controller.searchBarController.show()
          : controller.searchBarController.hide(),
      onMaxItemReached: controller.loadMorePosts,
      scrollThreshold: 0.7,
      scrollController: controller.scrollController,
    );
  }

  Widget buildError() {
    return Center(
      child: Text("OOPS something went wrong"),
    );
  }
}
