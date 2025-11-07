List<int> updateOrder(
  Set<int> allIds,
  Set<int> oldIds,
  Set<int> newIds,
) {
  // Handle empty inputs
  if (allIds.isEmpty) return [];
  if (oldIds.isEmpty) return allIds.toList();
  if (newIds.isEmpty) return []; // If newIds is empty, everything is deleted

  // Validate that oldIds and newIds are subsets of allIds
  if (!oldIds.every((id) => allIds.contains(id)) ||
      !newIds.every((id) => allIds.contains(id))) {
    return allIds.toList(); // Return original order if invalid IDs found
  }

  final allIdString = allIds.join(' ');
  final oldIdString = oldIds.join(' ');

  // Make sure sequence of IDs is the same
  if (!allIdString.contains(oldIdString)) {
    throw ArgumentError('Old IDs are not have the same sequence as all IDs');
  }

  // Remove any IDs in newIds that are not in oldIds
  final validNewIds = newIds.where((id) => oldIds.contains(id)).toSet();

  // Convert allIds to list and remove deleted items
  final toDelete = oldIds.difference(validNewIds);
  final result = allIds.where((id) => !toDelete.contains(id)).toList();

  // Check if there's any intersection between old and new IDs
  if (oldIds.intersection(validNewIds).isEmpty) return result;

  // Find the start index of the section to reorder
  final firstOldId = oldIds.firstWhere(
    (id) => result.contains(id),
    orElse: () => result.first,
  );
  final startIndex = result.indexOf(firstOldId);

  // Replace section with new order
  final newIdsOrdered = validNewIds.toList();
  for (
    var i = 0;
    i < newIdsOrdered.length && (startIndex + i) < result.length;
    i++
  ) {
    result[startIndex + i] = newIdsOrdered[i];
  }

  return result;
}
