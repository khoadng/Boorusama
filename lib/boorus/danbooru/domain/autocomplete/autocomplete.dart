class Autocomplete {
  Autocomplete({
    required this.type,
    required this.label,
    required this.value,
    required this.category,
    required this.postCount,
    // required this.antecedent,
  });
  // final dynamic antecedent;

  factory Autocomplete.fromJson(Map<String, dynamic> json) => Autocomplete(
        type: json['type'],
        label: json['label'],
        value: json['value'],
        category: json['category'],
        postCount: json['post_count'],
        // antecedent: json["antecedent"],
      );

  final String type;
  final String label;
  final String value;
  final int category;
  final int postCount;
}
