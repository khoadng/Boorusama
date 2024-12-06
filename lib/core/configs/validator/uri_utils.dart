// check if the uri is http or https
bool isHttpOrHttps(Uri uri) =>
    uri.host.isNotEmpty && (uri.scheme == 'http' || uri.scheme == 'https');

// check if the uri ends with a slash
bool endsWithSlash(Uri uri) => uri.path.endsWith('/');

// check if the uri contains www.
bool containsWww(Uri uri) => uri.host.startsWith('www.');
