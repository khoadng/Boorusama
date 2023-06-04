part of 'posts_provider.dart';

final danbooruPostDetailsArtistProvider = NotifierProvider.autoDispose
    .family<PostDetailsArtistNotifier, List<Recommend<DanbooruPost>>, int>(
  PostDetailsArtistNotifier.new,
  dependencies: [
    danbooruArtistCharacterPostRepoProvider,
  ],
);

final danbooruPostDetailsCharacterProvider = NotifierProvider.autoDispose
    .family<PostDetailsCharacterNotifier, List<Recommend<DanbooruPost>>, int>(
  PostDetailsCharacterNotifier.new,
  dependencies: [
    danbooruArtistCharacterPostRepoProvider,
  ],
);

final danbooruPostDetailsChildrenProvider = NotifierProvider.autoDispose
    .family<PostDetailsChildrenNotifier, List<DanbooruPost>, int>(
  PostDetailsChildrenNotifier.new,
  dependencies: [
    danbooruPostRepoProvider,
  ],
);

final danbooruPostDetailsNoteProvider = NotifierProvider.autoDispose
    .family<PostDetailsNoteNotifier, PostDetailsNoteState, Post>(
  PostDetailsNoteNotifier.new,
  dependencies: [
    danbooruNoteProvider,
  ],
);

final danbooruPostDetailsPoolsProvider = NotifierProvider.autoDispose
    .family<PostDetailsPoolsNotifier, List<Pool>, int>(
  PostDetailsPoolsNotifier.new,
  dependencies: [
    danbooruPoolRepoProvider,
  ],
);

final danbooruPostDetailsTagsProvider = NotifierProvider.autoDispose
    .family<PostDetailsTagsNotifier, List<PostDetailTag>, int>(
  PostDetailsTagsNotifier.new,
);
