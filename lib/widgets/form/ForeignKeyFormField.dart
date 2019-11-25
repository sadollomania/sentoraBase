import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/ForeignKeyFieldType.dart';

class ForeignKeyFormField extends FormField<BaseModel> {
  ForeignKeyFormField({
    @required ForeignKeyFieldType fieldType,
    FormFieldSetter<BaseModel> onSaved,
    FormFieldValidator<BaseModel> validator,
    BaseModel initialValue,
    bool autovalidate = false,
    bool enabled = true,
  }) : super(
      onSaved: onSaved,
      validator: validator,
      initialValue: initialValue,
      autovalidate: autovalidate,
      enabled: enabled,
      builder: (FormFieldState<BaseModel> state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(fieldType.fieldLabel),
            SizedBox(width: 10,),
            Expanded(
              child: FutureBuilder<List<BaseModel>>(
                future: BaseModel.getList(fieldType.foreignKeyModel),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return DropdownButton<String>(
                    items: snapshot.data.map((dropdownKayit) => DropdownMenuItem<String>(
                      child: Container(
                        child: Text(dropdownKayit.getListTileTitleValue()),
                      ),
                      value: dropdownKayit.get("ID") as String,
                    )).toList(),
                    onChanged: (String dropdownKayitId) {
                      BaseModel.getById(fieldType.foreignKeyModel.modelName, fieldType.foreignKeyModel.tableName, dropdownKayitId).then((newObj){
                        state.didChange(newObj);
                      });
                    },
                    isExpanded: true,
                    value: state.value != null ? state.value.get("ID") : null,
                    hint: Text(fieldType.fieldHint),
                  );
                },
              ),
            )
          ],
        );
      });
}
