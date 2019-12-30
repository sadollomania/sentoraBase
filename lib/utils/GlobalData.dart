class GlobalData {
  static final GlobalData _globalData = GlobalData._internal();

  factory GlobalData() {
    return _globalData;
  }

  GlobalData._internal();
}