extension DateTimeExtension on String {
  DateTime toDateFromTimeStamp() {
    return DateTime.parse(this).toLocal();
  }
}
