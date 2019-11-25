import 'dart:async';

import 'package:flutter/material.dart';

class NavigatorBase {
  static GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  static Future push(Widget widget) async {
    if(navigatorKey.currentState == null
      || navigatorKey.currentState.context == null) {
      return Future.delayed(Duration(milliseconds: 500), () {
        return push(widget);
      });
    } else {
      return navigatorKey.currentState.push(MaterialPageRoute<Null>(builder: (BuildContext context) {
        return widget;
      }));
    }
  }

  static void pop([bool result]) {
    if(navigatorKey.currentState == null
        || navigatorKey.currentState.context == null) {
      Future.delayed(Duration(milliseconds: 500), () {
        pop(result);
      });
    } else {
      navigatorKey.currentState.pop(result);
    }
  }
}