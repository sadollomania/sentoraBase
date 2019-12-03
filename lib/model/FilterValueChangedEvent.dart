class FilterValueChangedEvent {
  String fieldName;
  String mode;
  dynamic value;
  FilterValueChangedEvent(this.fieldName, this.mode, this.value);
}