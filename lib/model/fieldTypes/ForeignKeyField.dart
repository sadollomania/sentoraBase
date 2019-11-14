import 'package:meta/meta.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';

class ForeignKeyField extends BaseFieldType {
  final String foreignKeyModelName;

  ForeignKeyField({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    @required bool nullable,
    @required this.foreignKeyModelName
  }) : super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable);
}