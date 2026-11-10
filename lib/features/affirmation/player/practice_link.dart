/// The public URL identifies this recording across the website and mobile apps.
abstract final class PracticeLink {
  static const String url =
      'https://asteria-calendar.com/practice/i-have-time/';
  static final Uri _canonical = Uri.parse(url);

  static bool matches(Uri uri) {
    if (uri.userInfo.isNotEmpty || uri.hasPort) return false;
    final String path = uri.path.endsWith('/')
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;
    return (uri.scheme == _canonical.scheme &&
            uri.host == _canonical.host &&
            '$path/' == _canonical.path) ||
        (uri.scheme == 'asteria' &&
            uri.host == 'practice' &&
            path == '/i-have-time');
  }
}
