import 'dart:convert';

T asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class Mark {
  Mark({
    this.name,
    this.package,
    this.component,
  });

  factory Mark.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : Mark(
          name: asT<String>(jsonRes['name']),
          package: asT<String>(jsonRes['package']),
          component: asT<String>(jsonRes['component']),
        );

  String name;
  String package;
  String component;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'package': package,
        'component': component,
      };

  Mark clone() =>
      Mark.fromJson(asT<Map<String, dynamic>>(jsonDecode(jsonEncode(this))));
}
