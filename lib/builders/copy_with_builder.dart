import 'package:build/build.dart' show Builder, BuilderOptions;
import 'package:source_gen/source_gen.dart' show SharedPartBuilder, Generator;

import '../generators/copy_with_generator.dart';

Builder copyWithBuilder(BuilderOptions options) {
  return SharedPartBuilder(
    const <Generator>[CopyWithGenerator()],
    'copyWith',
  );
}
