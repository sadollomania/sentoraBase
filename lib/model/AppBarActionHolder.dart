import 'package:flutter/material.dart';
import 'package:sentora_base/model/BaseModel.dart';

class AppBarActionHolder {
  String caption;
  Color color;
  IconData icon;
  Function(BuildContext context, BaseModel selectedKayit, String baseModelPageId, GlobalKey<ScaffoldState> scaffoldKey) onTap;

  AppBarActionHolder({
    @required this.caption,
    @required this.color,
    @required this.icon,
    @required this.onTap,
  });
}