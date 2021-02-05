class CreatedTime {
  final String _createdDate;

  CreatedTime(this._createdDate);

  DateTime get time => DateTime.parse(_createdDate);

  @override
  String toString() {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return "${diff.inSeconds} second${diff.inSeconds >= 2 ? 's' : ''} ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} minute${diff.inMinutes >= 2 ? 's' : ''} ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hour${diff.inHours >= 2 ? 's' : ''} ago";
      //TODO: handle other case of datetime here
    } else {
      if (diff.inDays < 31) {
        return "${diff.inDays} day${diff.inDays >= 2 ? 's' : ''} ago";
      } else if (diff.inDays < 365) {
        var month = diff.inDays ~/ 12;
        return "$month month${month >= 2 ? 's' : ''} ago";
      } else {
        var year = diff.inDays ~/ 365;
        return "$year year${year >= 2 ? 's' : ''} ago";
      }
    }
  }
}
