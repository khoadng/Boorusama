const red = 'red';
const green = 'green';
const yellow = 'yellow';
const blue = 'blue';
const magenta = 'magenta';
const cyan = 'cyan';
const white = 'white';

const end = '\x1B[0m';

String colorize(String message, String color) {
  final colorCode = _colorStringToColorCode(color);

  final buffer = StringBuffer()
    ..write(colorCode)
    ..write(message)
    ..write(end);
  return buffer.toString();
}

String _colorStringToColorCode(String color) => switch (color) {
  red => '\x1B[31m',
  green => '\x1B[32m',
  yellow => '\x1B[33m',
  blue => '\x1B[34m',
  magenta => '\x1B[35m',
  cyan => '\x1B[36m',
  white => '\x1B[37m',
  _ => '\x1B[33m',
};
