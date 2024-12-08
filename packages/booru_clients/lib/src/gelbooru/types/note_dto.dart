class NoteDto {

  NoteDto({
    this.id,
    this.body,
    this.width,
    this.height,
    this.y,
    this.x,
  });
  final int? id;
  final String? body;
  final int? width;
  final int? height;
  final int? y;
  final int? x;

  NoteDto copyWith({
    int? Function()? id,
    String? Function()? body,
    int? Function()? width,
    int? Function()? height,
    int? Function()? y,
    int? Function()? x,
  }) {
    return NoteDto(
      id: id != null ? id() : this.id,
      body: body != null ? body() : this.body,
      width: width != null ? width() : this.width,
      height: height != null ? height() : this.height,
      y: y != null ? y() : this.y,
      x: x != null ? x() : this.x,
    );
  }
}
