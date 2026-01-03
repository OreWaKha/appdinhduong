class DateHelper {
  static DateTime weekStart(DateTime d) {
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static DateTime weekEnd(DateTime d) {
    return weekStart(d).add(const Duration(days: 7));
  }
  
}
