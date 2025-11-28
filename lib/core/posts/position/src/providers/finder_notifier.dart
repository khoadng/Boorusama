// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/finder.dart';
import '../types/interpolation_finder.dart';
import '../types/location.dart';
import '../types/progress.dart';
import '../types/repo.dart';

final pageFinderProvider = NotifierProvider.autoDispose
    .family<PageFinderNotifier, PageFinderProgress, PageFinderConfig>(
      PageFinderNotifier.new,
    );

class PageFinderNotifier
    extends AutoDisposeFamilyNotifier<PageFinderProgress, PageFinderConfig> {
  @override
  PageFinderProgress build(PageFinderConfig arg) {
    return const PageFinderIdle();
  }

  Future<PageLocation?> findPage(PaginationSnapshot snapshot) async {
    final finder = InterpolationPageFinder(
      repository: arg.repository,
      searchChunkSize: arg.searchChunkSize,
      userChunkSize: arg.userChunkSize,
      fetchDelay: const Duration(milliseconds: 500),
      onProgress: (progress) {
        state = progress;
      },
    );

    try {
      final result = await finder.findPage(snapshot);
      return result;
    } on PageFinderBeyondLimitException catch (e) {
      state = PageFinderBeyondLimitProgress(e);
      return null;
    } on PageFinderServerException {
      state = const PageFinderFailedProgress('Server error occurred');
      return null;
    } catch (e) {
      state = PageFinderFailedProgress(e);
      return null;
    }
  }

  void reset() {
    state = const PageFinderIdle();
  }
}

class PageFinderConfig extends Equatable {
  const PageFinderConfig({
    required this.repository,
    required this.userChunkSize,
    this.searchChunkSize = 100,
  });

  final PageFinderRepository repository;
  final int searchChunkSize;
  final int userChunkSize;

  @override
  List<Object?> get props => [repository, searchChunkSize, userChunkSize];
}
