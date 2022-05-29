import 'package:timeago/timeago.dart' as timeago;

class CreatedTime {
  final DateTime _createdDate;

  CreatedTime(this._createdDate);

  DateTime get time => _createdDate;

  @override
  String toString() {
    final now = DateTime.now();
    final diff = now.difference(time);
    final ago = now.subtract(diff);

    return timeago.format(ago);
  }
}
