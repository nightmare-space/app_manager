import 'dart:convert';

import 'mark.dart';

T asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class Marks {
  Marks({
    this.mark,
  });

  factory Marks.fromJson(Map<String, dynamic> jsonRes) {
    if (jsonRes == null) {
      return null;
    }

    final List<Mark> mark = jsonRes['mark'] is List ? <Mark>[] : null;
    if (mark != null) {
      for (final dynamic item in jsonRes['mark']) {
        if (item != null) {
          mark.add(Mark.fromJson(asT<Map<String, dynamic>>(item)));
        }
      }
    }
    return Marks(
      mark: mark,
    );
  }

  List<Mark> mark;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mark': mark,
      };

  Marks clone() =>
      Marks.fromJson(asT<Map<String, dynamic>>(jsonDecode(jsonEncode(this))));
}
