import 'dart:convert';
import '../constant/enumerates.dart';

class WeekDayConverter {
  static String? encodeWeekDays(List<WeekDay>? weekDays) {
    if (weekDays == null) return null;
    return jsonEncode(weekDays.map((day) => day.index).toList());
  }

  static List<WeekDay>? decodeWeekDays(String? jsonString) {
    if (jsonString == null) return null;
    List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((index) => WeekDay.values[index]).toList();
  }
}
