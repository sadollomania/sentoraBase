class FormFieldValueChangedEvent {
  String sentoraFieldBaseStateUid;
  String textValue;
  dynamic realValue;
  FormFieldValueChangedEvent(this.sentoraFieldBaseStateUid, this.textValue, this.realValue);
}