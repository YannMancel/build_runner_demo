import 'package:analyzer/dart/element/element.dart'
    show Element, ClassElement, ConstructorElement, ParameterElement;
import 'package:build/build.dart' show BuildStep;
import 'package:source_gen/source_gen.dart'
    show GeneratorForAnnotation, ConstantReader;

import '../annotations/copy_with_annotation.dart';
import '../models/field_info.dart';

/// Code generator with [CopyWith] annotation
class CopyWithGenerator extends GeneratorForAnnotation<CopyWith> {
  const CopyWithGenerator();

  @override
  dynamic generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // The annotation must be on a class
    if (element is! ClassElement) throw '$element is not a ClassElement';

    final className = element.name;
    final typeParameterFullNames = _getTypeParameters(
      element: element,
      nameOnly: false,
    );
    final typeParameterNames = _getTypeParameters(element: element);

    return '''
    extension ${className}CopyWith$typeParameterFullNames on $className$typeParameterNames {
      ${_getCopyWithMethod(element: element)}
    }
    ''';
  }

  /// Gets the possible parameter names.
  ///
  /// When there is `class MyClass<T extends String, Y>`, if `nameOnly` is
  ///   - `true`  -> `<T, Y>`.
  ///   - `false` -> `<T extends String, Y>`.
  String _getTypeParameters({
    required ClassElement element,
    bool nameOnly = true,
  }) {
    final names = element.typeParameters
        .map(
          (e) => nameOnly ? e.name : e.getDisplayString(withNullability: false),
        )
        .join(',');

    return names.isNotEmpty ? '<$names>' : '';
  }

  /// Generates the complete `copyWith` method.
  String _getCopyWithMethod({required ClassElement element}) {
    final className = element.name;

    final typeParameterNames = _getTypeParameters(element: element);

    final input =
    element.fields.map((e) => '${e.type}? ${e.name},').join('\n');

    final output = element.fields
        .map((e) => '${e.name}: ${e.name} ?? this.${e.name},')
        .join('\n');

    return '''
    /// Creates a copy of [$className] instance.
    $className$typeParameterNames copyWith({
      $input
    }) {
      return $className$typeParameterNames(
        $output
      );
    }
    ''';
  }

  /// Generates a list of [FieldInfo] for each class field that will be a part
  /// of the code generation process.
  /// The resulting array is sorted by the field name. `Throws` on error.
  List<FieldInfo> _sortedConstructorFields({
    required ClassElement classElement,
  }) {
    final constructor = classElement.unnamedConstructor;
    if (constructor is! ConstructorElement) {
      throw 'Default ${classElement.name} constructor is missing';
    }

    final parameters = constructor.parameters;
    if (parameters is! List<ParameterElement> || parameters.isEmpty) {
      throw 'Unnamed constructor for ${classElement.name} has no parameters';
    }

    parameters.forEach((parameter) {
      if (!parameter.isNamed) {
        throw 'Unnamed constructor for ${classElement.name} contains '
            'unnamed parameter. Only named parameters are supported.';
      }
    });

    final fields = parameters
        .map((e) => FieldInfo(
              parameter: e,
              classElement: classElement,
            ))
        .toList(growable: false);

    fields.sort((a, b) => a.name.compareTo(b.name));

    return fields;
  }
}
