class NoteDto {
  NoteDto({
    required this.polygon,
    required this.text,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) => NoteDto(
    polygon: switch (json['polygon']) {
      List<dynamic> list =>
        list
            .map(
              (e) => switch (e) {
                List<dynamic> coords =>
                  coords
                      .map(
                        (coord) => switch (coord) {
                          num n => n.toDouble(),
                          _ => 0.0,
                        },
                      )
                      .toList(),
                _ => <double>[],
              },
            )
            .toList(),
      _ => [],
    },
    text: json['text'] as String?,
  );

  final List<List<double>> polygon;
  final String? text;
}
