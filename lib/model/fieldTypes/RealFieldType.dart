import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sentora_base/model/BaseModel.dart';
import 'package:sentora_base/model/fieldTypes/BaseFieldType.dart';
import 'package:sentora_base/widgets/form/field/RealField.dart';
import 'package:sentora_base/widgets/form/filterField/RealFilterField.dart';

class RealFieldType extends BaseFieldType {
  static final List<String> filterModes = List<String>.from(["realeq","realgt","reallt"]);
  static final List<String> filterModeTitles = List<String>.from(["=",">","<"]);

  final int length;
  final int minLength;
  final int maxLength;
  final int fractionLength;
  final bool signed;

  RealFieldType({
    @required String fieldLabel,
    @required String fieldHint,
    @required String name,
    bool nullable,
    double defaultValue,
    bool unique = false,
    this.length = -1,
    this.minLength = -1,
    this.maxLength = -1,
    this.fractionLength = -1,
    this.signed = false,
    bool Function(BaseModel baseModel) nullableFn,
    bool sortable = true,
    bool filterable = true,
  }) : assert(length == -1 || length > 0),
        assert(length == -1 || ( minLength == -1 && maxLength == -1 )),
        assert(minLength == -1 || minLength > 0),
        assert(maxLength == -1 || maxLength > 0),
        assert(maxLength >= minLength),
        assert(fractionLength == -1 || fractionLength > 0),
        super(fieldLabel:fieldLabel, fieldHint:fieldHint, name:name, nullable:nullable, multiple: false, unique: unique, defaultValue: defaultValue, nullableFn : nullableFn, sortable : sortable, filterable : filterable);

  @override
  List<String> getFilterModes() {
    return List<String>.from(["realeq","realgt","reallt"]);
  }

  @override
  List<String> getFilterModeTitles() {
    return List<String>.from(["=",">","<"]);
  }

  @override
  Widget constructFilterField(BuildContext context, Map<String, dynamic> filterMap, int filterIndex, GlobalKey<ScaffoldState> scaffoldKey) {
    return RealFilterField(
      context: context,
      fieldType: this,
      filterIndex: filterIndex,
      filterMap: filterMap,
      scaffoldKey: scaffoldKey,
    );
  }

  @override
  Widget constructFormField(BuildContext context, BaseModel kayit, bool lastField, GlobalKey<ScaffoldState> scaffoldKey) {
    return RealField(
      context: context,
      fieldType: this,
      kayit: kayit,
      lastField: lastField,
      scaffoldKey: scaffoldKey,
    );
  }
}