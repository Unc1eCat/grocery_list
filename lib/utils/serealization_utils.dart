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

abstract class ToJson {
  Object toJson();
}

// abstract class FieldsNameValueMapable {
//   Map<String, Object> get fieldsNameValueMap;
// }

// mixin FieldsToJson implements ToJson, FieldsNameValueMapable {
//   @override
//   Object toJson() => fieldsNameValueMap.toJson();
// }
