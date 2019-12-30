import 'package:flutter/material.dart';

class StateData {
  BuildContext context;
  GlobalKey<ScaffoldState> scaffoldKey;
  String pageId;
  dynamic tag;
  TabController tabController;

  StateData({
    this.context,
    this.scaffoldKey,
    this.pageId,
    this.tag,
    this.tabController,
  });
}