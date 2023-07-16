import 'dart:async';
import 'dart:developer';

import 'package:uuid/uuid.dart';

void main() {
  for (int i = 0; i < 10; i++) {
    log(getUuid(), zone: Zone.current);
  }
}

String getUuid() {
  final String uuid = const Uuid().v4(options: {"hex": true});
  return uuid;
}


// void main() {
//   // final List<String?> result = <String?>["abc", null];
//   // final Iterable<String?> errorMessages =
//   //     result.where((String? element) => element != null);
//   // final finalMessage = errorMessages.isEmpty ? null : errorMessages.join("\n");
//   // assert(finalMessage == "abc");
// }