// extension ObjectToJson on Object {
//   Object toJson() {
//     if (this is Iterable) {
//       return (this as Iterable).toJson();
//     } else if (this is Map<String, dynamic>) {
//       return (this as Map<String, dynamic>).toJson();
//     } else if (this is ToJson) {
//       return (this as ToJson).toJson();
//     } else if (this is num || this is bool || this is String || this == null || this is Map<String, dynamic>) {
//       return this;
//     } else {
//       throw UnsupportedError(
//           'The object "$this" of type "${this.runtimeType}" can\'t be converted to List-Map Json representation. Only primitives, "ToJson" implementors, "String"-keyed maps and iterables can be converted to List-Map Json representation.');
//     }
//   }
// }

// extension IterableToJson<T extends Object> on Iterable<T> {
//   List<T> toJson() => map(
//         (e) {
//           e.toJson();
//         },
//       ).toList();
// }

// extension MapToJson<T extends Object> on Map<String, T> {
//   Map<String, T> toJson() => map(
//         (k, v) => MapEntry(k, v.toJson()),
//       );
// }

import 'dart:convert';

abstract class ToJson {
  Object toJson();

  static Object toEncodable(Object value) {
    if (value is Iterable) {
      return value.toList();
    } else if (value is ToJson) {
      return value.toJson();
    } else if (value is num || value is bool || value is String || value == null || value is Map<String, dynamic>) {
      return value;
    } else {
      throw UnsupportedError(
          'The object "$value" of type "${value.runtimeType}" can\'t be converted to List-Map Json representation. Only primitives, "ToJson" implementors, "String"-keyed maps and iterables can be converted to List-Map Json representation.');
    }
  }
}

var jsonEncoder = JsonEncoder.withIndent('    ', ToJson.toEncodable);

// abstract class FieldsNameValueMapable {
//   Map<String, Object> get fieldsNameValueMap;
// }

// mixin FieldsToJson implements ToJson, FieldsNameValueMapable {
//   @override
//   Object toJson() => fieldsNameValueMap.toJson();
// }
