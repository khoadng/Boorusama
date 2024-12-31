enum GeneralPostQualityType {
  preview,
  sample,
  original,
}

extension GeneralPostQualityTypeX on GeneralPostQualityType {
  String stringify() => switch (this) {
        GeneralPostQualityType.preview => 'preview',
        GeneralPostQualityType.sample => 'sample',
        GeneralPostQualityType.original => 'original',
      };
}

GeneralPostQualityType stringToGeneralPostQualityType(String? value) =>
    switch (value) {
      'preview' => GeneralPostQualityType.preview,
      'sample' => GeneralPostQualityType.sample,
      'original' => GeneralPostQualityType.original,
      _ => GeneralPostQualityType.sample,
    };
