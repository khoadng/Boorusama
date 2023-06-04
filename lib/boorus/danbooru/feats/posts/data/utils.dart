List<String> splitTag(String? tags) => tags == null
    ? []
    : tags.isEmpty
        ? []
        : tags.split(' ');
