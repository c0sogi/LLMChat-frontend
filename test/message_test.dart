void main() {
  final List<String?> result = <String?>["abc", null];
  final Iterable<String?> errorMessages =
      result.where((String? element) => element != null);
  final finalMessage = errorMessages.isEmpty ? null : errorMessages.join("\n");
  assert(finalMessage == "abc");
}
