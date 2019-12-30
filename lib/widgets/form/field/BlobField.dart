import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BlobFieldType.dart';
import 'package:sentora_base/widgets/form/field/BaseField.dart';

class BlobField extends BaseField {
  BlobField({
    @required BuildContext context,
    @required BlobFieldType fieldType,
    @required BaseModel kayit,
    @required bool lastField,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  }) : super(
      context: context,
      kayit: kayit,
      fieldType: fieldType,
      textValue: "",
      realValue : kayit.get(fieldType.name),
      lastField : lastField,
      onSaved : (textValue, realValue) {
        kayit.set(fieldType.name, realValue);
      },
      extraValidator : (textValue, realValue) {
        return null;
      },
      scaffoldKey : scaffoldKey
  );
}