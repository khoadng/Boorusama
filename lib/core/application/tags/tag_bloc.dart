// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/domain/tags/tag.dart';
import 'package:boorusama/core/domain/tags/tag_category.dart';
import 'package:boorusama/core/domain/tags/tag_repository.dart';
import 'package:boorusama/utils/collection_utils.dart';

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
    this.onResult,
  });

  final List<String> tags;
  final void Function(List<TagGroupItem> tags)? onResult;

  @override
  List<Object?> get props => [tags, onResult];
}

class TagBloc extends Bloc<TagEvent, TagState> {
  TagBloc({
    required TagRepository tagRepository,
  }) : super(TagState.initial()) {
    on<TagFetched>(
      (event, emit) async {
        emit(TagState.initial());

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
            event.onResult?.call(group);
            emit(state.copyWith(
              tags: group,
              status: LoadStatus.success,
            ));
          },
        );
      },
      transformer: restartable(),
    );
  }
}

class TagGroupItem extends Equatable {
  const TagGroupItem({
    required this.groupName,
    required this.tags,
    required this.order,
  });

  final String groupName;
  final List<Tag> tags;
  final TagCategoryOrder order;

  @override
  List<Object?> get props => [groupName, tags, order];
}

String tagCategoryToString(TagCategory category) => switch (category) {
      TagCategory.artist => 'Artist',
      TagCategory.charater => 'Character',
      TagCategory.copyright => 'Copyright',
      TagCategory.general => 'General',
      TagCategory.meta => 'Meta',
      TagCategory.invalid_ => ''
    };

typedef TagCategoryOrder = int;

TagCategoryOrder tagCategoryToOrder(TagCategory category) => switch (category) {
      TagCategory.artist => 0,
      TagCategory.copyright => 1,
      TagCategory.charater => 2,
      TagCategory.general => 3,
      TagCategory.meta => 4,
      TagCategory.invalid_ => 5
    };
