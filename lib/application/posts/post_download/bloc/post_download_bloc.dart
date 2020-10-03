import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'post_download_event.dart';
part 'post_download_state.dart';

class PostDownloadBloc extends Bloc<PostDownloadEvent, PostDownloadState> {
  PostDownloadBloc() : super(PostDownloadInitial());

  @override
  Stream<PostDownloadState> mapEventToState(
    PostDownloadEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
