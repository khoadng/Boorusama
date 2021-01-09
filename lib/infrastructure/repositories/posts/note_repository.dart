import 'package:boorusama/domain/posts/i_note_repository.dart';
import 'package:boorusama/domain/posts/note.dart';
import 'package:boorusama/domain/posts/note_coordinate.dart';
import 'package:boorusama/infrastructure/apis/i_api.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;

class NoteRepository implements INoteRepository {
  final IApi _api;

  NoteRepository(this._api);

  @override
  Future<List<Note>> getNotesFrom(int postId) =>
      _api.getNotes(postId).then((value) {
        final data = value.response.data.toString();
        final document = html.parse(data);

        final notesNode = document.documentElement
            .querySelector("section[id='notes']")
            .children;

        final notes = List<Note>();

        for (var node in notesNode) {
          var w = node.attributes["data-width"];
          var h = node.attributes["data-height"];
          var x = node.attributes["data-x"];
          var y = node.attributes["data-y"];
          var coord = NoteCoordinate(double.parse(x), double.parse(y),
              double.parse(w), double.parse(h));
          var content = node.attributes["data-body"];
          notes.add(Note(coord, content));
        }

        return notes;
      }).catchError((Object obj) {
        switch (obj.runtimeType) {
          case DioError:
            throw Exception("Failed to get comments from $postId");
            break;
          default:
        }
        return List<Note>();
      });
}
