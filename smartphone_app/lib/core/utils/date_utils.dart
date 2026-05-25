extension DateTimeExt on DateTime {
  String toDateString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  int toUnixTimestamp() => millisecondsSinceEpoch ~/ 1000;

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

extension IntExt on int {
  DateTime toDateTime() =>
      DateTime.fromMillisecondsSinceEpoch(this * 1000);
}
