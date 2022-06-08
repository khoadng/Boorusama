// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/pool/pool_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class PoolPage extends StatefulWidget {
  PoolPage({Key? key}) : super(key: key);

  @override
  State<PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  final ValueNotifier<PoolCategory> _currentCategory =
      ValueNotifier(PoolCategory.series);

  @override
  void initState() {
    super.initState();
    context.read<PoolCubit>().getPools(_currentCategory.value);
    _currentCategory.addListener(() {
      context.read<PoolCubit>().getPools(_currentCategory.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: BlocBuilder<PoolCubit, AsyncLoadState<List<PoolItem>>>(
            builder: (context, state) {
              if (state.status == LoadStatus.success) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.all(3.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      child: GestureDetector(
                        onTap: () => AppRouter.router.navigateTo(
                          context,
                          'pool/detail',
                          routeSettings: RouteSettings(arguments: [
                            state.data![index].poolName,
                            state.data![index].poolDescription,
                            state.data![index].postIds,
                            state.data![index].lastUpdated,
                          ]),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: _buildPoolImage(state.data![index]),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                state.data![index].poolName,
                                style: TextStyle(color: Colors.black),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  itemCount: state.data!.length,
                );
              } else if (state.status == LoadStatus.failure) {
                return Center(
                  child: Text("Failed to load pool, please try again later"),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPoolImage(PoolItem pool) => Stack(
        children: [
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            imageUrl: pool.coverUrl,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              color: Theme.of(context).cardColor,
              height: 25,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    pool.postCount.toString(),
                  ),
                  FaIcon(FontAwesomeIcons.image)
                ],
              ),
            ),
          )
        ],
      );

  Widget _buildHeader() => ValueListenableBuilder<PoolCategory>(
        valueListenable: _currentCategory,
        builder: (context, category, child) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                primary: Theme.of(context).textTheme.headline6!.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              onPressed: () => showMaterialModalBottomSheet(
                  context: context,
                  builder: (context) => Material(
                        child: SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: Text('Series'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _currentCategory.value = PoolCategory.series;
                                },
                              ),
                              ListTile(
                                title: Text('Collection'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _currentCategory.value =
                                      PoolCategory.collection;
                                },
                              ),
                            ],
                          ),
                        ),
                      )),
              child: Row(
                children: <Widget>[
                  Text(poolCategoryToDisplayString(category).toUpperCase()),
                  Icon(Icons.arrow_drop_down)
                ],
              ),
            )
          ],
        ),
      );
}

String poolCategoryToDisplayString(PoolCategory category) =>
    "${category.toString().split('.').last.replaceAll('()', '')}";
