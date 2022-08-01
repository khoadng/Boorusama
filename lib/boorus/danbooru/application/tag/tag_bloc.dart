// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/common/collection_utils.dart';

class TagState extends Equatable {
  const TagState({
    required this.tags,
    required this.status,
  });

  factory TagState.initial() => const TagState(
        tags: null,
        status: LoadStatus.initial,
      );

  final List<TagGroupItem>? tags;
  final LoadStatus status;

  TagState copyWith({
    List<TagGroupItem>? tags,
    LoadStatus? status,
  }) =>
      TagState(
        tags: tags ?? this.tags,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [tags];
}

abstract class TagEvent extends Equatable {
  const TagEvent();
}

class TagFetched extends TagEvent {
  const TagFetched({
    required this.tags,
  });

  final List<String> tags;

  @override
  List<Object?> get props => [tags];
}

class TagReset extends TagEvent {
  const TagReset();

  @override
  List<Object?> get props => [];
}

class TagBloc extends Bloc<TagEvent, TagState> {
  TagBloc({
    required ITagRepository tagRepository,
  }) : super(TagState.initial()) {
    on<TagFetched>(
      (event, emit) async {
        await tryAsync<List<Tag>>(
          action: () => tagRepository.getTagsByNameComma(
            event.tags.join(','),
            1,
          ),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
          onSuccess: (tags) async {
            tags.sort((a, b) => a.rawName.compareTo(b.rawName));
            final group = tags
                .groupBy((e) => e.category)
                .entries
                .map((e) => TagGroupItem(
                      groupName: tagCategoryToString(e.key),
                      tags: e.value,
                      order: tagCategoryToOrder(e.key),
                    ))
                .toList()
              ..sort((a, b) => a.order.compareTo(b.order));
            emit(state.copyWith(
              tags: group,
              status: LoadStatus.success,
            ));
          },
        );
      },
      transformer: restartable(),
    );

    on<TagReset>((event, emit) {
      emit(TagState.initial());
    });
  }
}

class TagGroupItem {
  TagGroupItem({
    required this.groupName,
    required this.tags,
    required this.order,
  });

  final String groupName;
  final List<Tag> tags;
  final TagCategoryOrder order;
}

String tagCategoryToString(TagCategory category) {
  switch (category) {
    case TagCategory.artist:
      return 'Artist';
    case TagCategory.charater:
      return 'Character';
    case TagCategory.copyright:
      return 'Copyright';
    case TagCategory.general:
      return 'General';
    case TagCategory.meta:
      return 'Meta';
    default:
      return '';
  }
}
