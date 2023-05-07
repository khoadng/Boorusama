String formatDurationForMedia(Duration duration) {
  final seconds = duration.inSeconds % 60;
  final minutes = duration.inMinutes % 60;
  final hours = duration.inHours;

  final secondsStr = seconds.toString().padLeft(2, '0');
  final minutesStr = minutes.toString();
  final hoursStr = hours.toString();

  if (hours > 0) {
    return '$hoursStr:$minutesStr:$secondsStr';
  } else {
    return '$minutesStr:$secondsStr';
  }
}
