// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads/downloads.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class MockPostDownloadBloc
    extends MockBloc<DownloadEvent<String, Post>, DownloadState<Post>>
    implements BulkPostDownloadBloc {}

void main() {
  final downloadBloc = MockPostDownloadBloc();

  blocTest<BulkImageDownloadBloc, BulkImageDownloadState>(
    'enter a tag will switch from empty view to tag confirmation state',
    build: () => BulkImageDownloadBloc(
      permissionChecker: () async => PermissionStatus.granted,
      permissionRequester: () async => PermissionStatus.granted,
      bulkPostDownloadBloc: downloadBloc,
    ),
    act: (bloc) => bloc.add(const BulkImageDownloadTagsAdded(tags: ['foo'])),
    expect: () => [
      BulkImageDownloadState.initial().copyWith(
        status: BulkImageDownloadStatus.dataSelected,
        selectedTags: [
          'foo',
        ],
      ),
    ],
  );

  blocTest<BulkImageDownloadBloc, BulkImageDownloadState>(
    'have 1 tag, add another tag',
    seed: () => BulkImageDownloadState.initial().copyWith(
      status: BulkImageDownloadStatus.dataSelected,
      selectedTags: [
        'bar',
      ],
    ),
    build: () => BulkImageDownloadBloc(
      permissionChecker: () async => PermissionStatus.granted,
      permissionRequester: () async => PermissionStatus.granted,
      bulkPostDownloadBloc: downloadBloc,
    ),
    act: (bloc) => bloc.add(const BulkImageDownloadTagsAdded(tags: ['foo'])),
    expect: () => [
      BulkImageDownloadState.initial().copyWith(
        status: BulkImageDownloadStatus.dataSelected,
        selectedTags: [
          'bar',
          'foo',
        ],
      ),
    ],
  );

  blocTest<BulkImageDownloadBloc, BulkImageDownloadState>(
    'have 1 tag, remove 1 tag',
    seed: () => BulkImageDownloadState.initial().copyWith(
      status: BulkImageDownloadStatus.dataSelected,
      selectedTags: [
        'bar',
      ],
    ),
    build: () => BulkImageDownloadBloc(
      permissionChecker: () async => PermissionStatus.granted,
      permissionRequester: () async => PermissionStatus.granted,
      bulkPostDownloadBloc: downloadBloc,
    ),
    act: (bloc) => bloc.add(const BulkImagesDownloadRequested(tags: ['bar'])),
    expect: () => [
      BulkImageDownloadState.initial().copyWith(
        status: BulkImageDownloadStatus.downloadInProgress,
        selectedTags: [
          'bar',
        ],
      ),
    ],
  );

  blocTest<BulkImageDownloadBloc, BulkImageDownloadState>(
    'request download will switch to download progress state',
    seed: () => BulkImageDownloadState.initial().copyWith(
      status: BulkImageDownloadStatus.dataSelected,
      selectedTags: [
        'bar',
      ],
    ),
    build: () => BulkImageDownloadBloc(
      permissionChecker: () async => PermissionStatus.granted,
      permissionRequester: () async => PermissionStatus.granted,
      bulkPostDownloadBloc: downloadBloc,
    ),
    act: (bloc) => bloc.add(const BulkImageDownloadTagRemoved(tag: 'bar')),
    expect: () => [
      BulkImageDownloadState.initial().copyWith(
        status: BulkImageDownloadStatus.dataSelected,
        selectedTags: [],
      ),
    ],
  );

  blocTest<BulkImageDownloadBloc, BulkImageDownloadState>(
    'when download done, hit reset to back to empty state',
    seed: () => BulkImageDownloadState.initial().copyWith(
      status: BulkImageDownloadStatus.done,
      selectedTags: [
        'bar',
      ],
    ),
    build: () => BulkImageDownloadBloc(
      permissionChecker: () async => PermissionStatus.granted,
      permissionRequester: () async => PermissionStatus.granted,
      bulkPostDownloadBloc: downloadBloc,
    ),
    act: (bloc) => bloc.add(const BulkImageDownloadReset()),
    expect: () => [
      BulkImageDownloadState.initial(),
    ],
  );
}
