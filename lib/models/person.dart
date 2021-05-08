import 'package:flutter/foundation.dart';

import '../annotations/copy_with_annotation.dart';

part 'person.g.dart';

// Warning: Only this configuration can be build with success with build_runner.
@immutable
@CopyWith()
class Person<T extends Object> {
  const Person({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;
}
