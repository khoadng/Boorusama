class NoteDto {
  final int? id;
  final String? body;
  final int? width;
  final int? height;
  final int? top;
  final int? left;

  NoteDto({
    this.id,
    this.body,
    this.width,
    this.height,
    this.top,
    this.left,
  });

  NoteDto copyWith({
    int? Function()? id,
    String? Function()? body,
    int? Function()? width,
    int? Function()? height,
    int? Function()? top,
    int? Function()? left,
  }) {
    return NoteDto(
      id: id != null ? id() : this.id,
      body: body != null ? body() : this.body,
      width: width != null ? width() : this.width,
      height: height != null ? height() : this.height,
      top: top != null ? top() : this.top,
      left: left != null ? left() : this.left,
    );
  }
}
