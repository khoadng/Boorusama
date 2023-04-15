// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/downloads.dart';

class MockPostDownloadBloc extends MockBloc<DownloadEvent<String, DanbooruPost>,
    DownloadState<DanbooruPost>> implements DanbooruBulkDownloadBloc {}

void main() {
  final downloadBloc = MockPostDownloadBloc();

  blocTest<BulkDownloadManagerBloc, BulkDownloadManagerState>(
    'enter a tag will switch from empty view to tag confirmation state',
    build: () => BulkDownloadManagerBloc(
      permissionChecker: () async => PermissionStatus.granted,
      permissionRequester: () async => PermissionStatus.granted,
      bulkPostDownloadBloc: downloadBloc,
    ),
    act: (bloc) => bloc.add(const BulkDownloadManagerTagsAdded(tags: ['foo'])),
    expect: () => [
      BulkDownloadManagerState.initial().copyWith(
        status: BulkDownloadManagerStatus.dataSelected,
        selectedTags: [
          'foo',
        ],
      ),
    ],
  );

  blocTest<BulkDownloadManagerBloc, BulkDownloadManagerState>(
    'have 1 tag, add another tag',
    seed: () => BulkDownloadManagerState.initial().copyWith(
      status: BulkDownloadManagerStatus.dataSelected,
      selectedTags: [
        'bar',
      ],
    ),
    build: () => BulkDownloadManagerBloc(
      permissionChecker: () async => PermissionStatus.granted,
      permissionRequester: () async => PermissionStatus.granted,
      bulkPostDownloadBloc: downloadBloc,
    ),
    act: (bloc) => bloc.add(const BulkDownloadManagerTagsAdded(tags: ['foo'])),
    expect: () => [
      BulkDownloadManagerState.initial().copyWith(
        status: BulkDownloadManagerStatus.dataSelected,
        selectedTags: [
          'bar',
          'foo',
        ],
      ),
    ],
  );

  blocTest<BulkDownloadManagerBloc, BulkDownloadManagerState>(
    'have 1 tag, remove 1 tag',
    seed: () => BulkDownloadManagerState.initial().copyWith(
      status: BulkDownloadManagerStatus.dataSelected,
      selectedTags: [
        'bar',
      ],
    ),
    build: () => BulkDownloadManagerBloc(
      permissionChecker: () async => PermissionStatus.granted,
      permissionRequester: () async => PermissionStatus.granted,
      bulkPostDownloadBloc: downloadBloc,
    ),
    act: (bloc) => bloc.add(const BulkDownloadManagerRequested(tags: ['bar'])),
    expect: () => [
      BulkDownloadManagerState.initial().copyWith(
        status: BulkDownloadManagerStatus.downloadInProgress,
        selectedTags: [
          'bar',
        ],
      ),
    ],
  );

  blocTest<BulkDownloadManagerBloc, BulkDownloadManagerState>(
    'request download will switch to download progress state',
    seed: () => BulkDownloadManagerState.initial().copyWith(
      status: BulkDownloadManagerStatus.dataSelected,
      selectedTags: [
        'bar',
      ],
    ),
    build: () => BulkDownloadManagerBloc(
      permissionChecker: () async => PermissionStatus.granted,
      permissionRequester: () async => PermissionStatus.granted,
      bulkPostDownloadBloc: downloadBloc,
    ),
    act: (bloc) => bloc.add(const BulkDownloadManagerTagRemoved(tag: 'bar')),
    expect: () => [
      BulkDownloadManagerState.initial().copyWith(
        status: BulkDownloadManagerStatus.dataSelected,
        selectedTags: [],
      ),
    ],
  );

  blocTest<BulkDownloadManagerBloc, BulkDownloadManagerState>(
    'when download done, hit reset to back to empty state',
    seed: () => BulkDownloadManagerState.initial().copyWith(
      status: BulkDownloadManagerStatus.done,
      selectedTags: [
        'bar',
      ],
    ),
    build: () => BulkDownloadManagerBloc(
      permissionChecker: () async => PermissionStatus.granted,
      permissionRequester: () async => PermissionStatus.granted,
      bulkPostDownloadBloc: downloadBloc,
    ),
    act: (bloc) => bloc.add(const BulkDownloadManagerReset()),
    expect: () => [
      BulkDownloadManagerState.initial(),
    ],
  );
}
