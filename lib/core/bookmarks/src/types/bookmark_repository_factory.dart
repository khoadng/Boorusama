// Project imports:
import 'bookmark_repository.dart';

abstract interface class BookmarkRepositoryFactory {
  Future<BookmarkRepository> create();

  Future<void> dispose(BookmarkRepository repository);
}
