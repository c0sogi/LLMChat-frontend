void main() {
  const int timestamp = 20120227132700;
  final String timecode = timestamp.toString();
  DateTime dateTime =
      DateTime.parse("${timecode.substring(0, 8)}T${timecode.substring(8)}");
  assert(dateTime.year == 2020);
  assert(dateTime.month == 12);
  assert(dateTime.day == 27);
  assert(dateTime.hour == 13);
  assert(dateTime.minute == 27);
  assert(dateTime.second == 0);
}
