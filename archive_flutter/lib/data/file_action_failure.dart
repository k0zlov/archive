class FileActionFailure implements Exception {
  const FileActionFailure(this.message);
  final String message;
  @override
  String toString() => message;
}
