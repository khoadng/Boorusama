abstract class UploaderQuery {
  String resolveTag();
  String resolveDisplayName();
}

class UserColonUploaderQuery with _UserDisplayX implements UploaderQuery {
  const UserColonUploaderQuery(this.username);

  @override
  final String username;

  @override
  String resolveTag() => 'user:$username';
}

class UserEqualsUploaderQuery with _UserDisplayX implements UploaderQuery {
  const UserEqualsUploaderQuery(this.username);

  @override
  final String username;

  @override
  String resolveTag() => 'user=$username';
}

class UploaderColonUploaderQuery with _UserDisplayX implements UploaderQuery {
  const UploaderColonUploaderQuery(this.username);

  @override
  final String username;

  @override
  String resolveTag() => 'uploader:$username';
}

mixin _UserDisplayX implements UploaderQuery {
  String get username;

  @override
  String resolveDisplayName() => username;
}
