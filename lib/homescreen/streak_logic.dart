int calculateStreak(Iterable<DateTime> activities, DateTime now) {
  DateTime day(DateTime date) => DateTime.utc(date.year, date.month, date.day);
  final days = activities.map((d) => day(d.toLocal())).toSet();
  var cursor = day(now);
  if (!days.contains(cursor)) cursor = cursor.subtract(const Duration(days: 1));
  var count = 0;
  while (days.contains(cursor)) {
    count++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return count;
}
