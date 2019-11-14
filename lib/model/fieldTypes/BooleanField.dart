import 'package:meta/meta.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';

class BooleanField extends BaseFieldType {
  BooleanField({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required bool nullable,
    bool defaultValue,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, defaultValue: defaultValue);
}