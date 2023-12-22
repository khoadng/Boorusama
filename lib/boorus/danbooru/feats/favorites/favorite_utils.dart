String buildFavoriteQuery(String username) =>
    'ordfav:${username.replaceAll(' ', '_')}'.trim();
