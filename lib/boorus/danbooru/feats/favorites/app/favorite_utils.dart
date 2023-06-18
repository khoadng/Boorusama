String buildFavoriteQuery(String username) =>
    'ordfav:${username.replaceAll(' ', '_')}';
