import 'package:flutter/material.dart';

class StateData {
  BuildContext context;
  GlobalKey<ScaffoldState> scaffoldKey;
  String pageId;
  dynamic tag;
  TabController? tabController;

  StateData({
    required this.context,
    required this.scaffoldKey,
    required this.pageId,
    this.tag,
    this.tabController,
  });
}