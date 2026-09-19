Map<String, String> buildGelbooruSessionHeaders({
  required String userId,
  required String passHash,
}) => {
  'Cookie': 'user_id=$userId; pass_hash=$passHash',
};
