class NoteCoordinate {
  NoteCoordinate(
    this._x,
    this._y,
    this._width,
    this._height,
  );
  final double _x;
  final double _y;
  final double _width;
  final double _height;

  double get x => _x;

  double get y => _y;

  double get width => _width;

  double get height => _height;

  NoteCoordinate calibrate(
    double screenHeight,
    double screenWidth,
    double screenAspectRatio,
    double postHeight,
    double postWidth,
    double postAspectRatio,
  ) {
    var aspectRatio = 1.0;
    double offset = 0;
    double newX;
    double newY;
    double newWidth;
    double newHeight;

    if (screenHeight > screenWidth) {
      if (screenAspectRatio < postAspectRatio) {
        aspectRatio = screenWidth / postWidth;
        offset = (screenHeight - aspectRatio * postHeight) / 2;
        newX = x * aspectRatio;
        newY = y * aspectRatio + offset;
      } else {
        aspectRatio = screenHeight / postHeight;
        offset = (screenWidth - aspectRatio * postWidth) / 2;
        newX = x * aspectRatio + offset;
        newY = y * aspectRatio;
      }
    } else {
      if (screenAspectRatio > postAspectRatio) {
        aspectRatio = screenHeight / postHeight;
        offset = (screenWidth - aspectRatio * postWidth) / 2;
        newX = x * aspectRatio + offset;
        newY = y * aspectRatio;
      } else {
        aspectRatio = screenWidth / postWidth;
        offset = (screenHeight - aspectRatio * postHeight) / 2;
        newX = x * aspectRatio;
        newY = y * aspectRatio + offset;
      }
    }

    newWidth = width * aspectRatio;
    newHeight = height * aspectRatio;

    return NoteCoordinate(
      newX,
      newY,
      newWidth,
      newHeight,
    );
  }
}
