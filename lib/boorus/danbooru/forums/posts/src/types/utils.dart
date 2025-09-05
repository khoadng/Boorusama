class DanbooruForumUtils {
  const DanbooruForumUtils._();

  static const postPerPage = 20;

  static int getFirstPageKey({
    required int responseCount,
  }) => (responseCount / postPerPage).ceil();
}
