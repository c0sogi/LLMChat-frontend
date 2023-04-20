void main() {
  const int timestamp = 20120227132700;
  final String timecode = timestamp.toString();
  DateTime dateTime =
      DateTime.parse("${timecode.substring(0, 8)}T${timecode.substring(8)}");
  print(dateTime);
}
