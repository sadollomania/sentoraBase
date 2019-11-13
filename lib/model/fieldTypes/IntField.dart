import 'package:meta/meta.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';

class IntField extends BaseFieldType {
  IntField({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required bool nullable,
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable);
}