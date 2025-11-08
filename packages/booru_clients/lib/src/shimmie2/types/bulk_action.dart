enum BulkAction {
  favorite('bulk_favorite'),
  unfavorite('bulk_unfavorite');

  const BulkAction(this.value);

  final String value;
}
