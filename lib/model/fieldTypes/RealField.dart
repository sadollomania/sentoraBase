import 'package:meta/meta.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';

class RealField extends BaseFieldType {
  RealField({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required bool nullable,
    double defaultValue,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, defaultValue: defaultValue);
}