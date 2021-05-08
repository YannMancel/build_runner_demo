import 'package:analyzer/dart/element/element.dart'
    show ClassElement, ParameterElement;

class FieldInfo {
  const FieldInfo({
    required ParameterElement parameter,
    required ClassElement classElement,
  })   : _parameter = parameter,
        _classElement = classElement;

  final ParameterElement _parameter;
  final ClassElement _classElement;

  String get name => _parameter.name;

  @override
  String toString() {
    return '''
    FieldInfo {
      parameter ${_parameter.name}, 
      classElement ${_classElement.name}
    ''';
  }
}
