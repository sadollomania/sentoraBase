import 'dart:async';

import 'package:flutter/material.dart';

class NavigatorBase {
  static GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  static Future push(Widget widget) async {
    if (navigatorKey.currentState == null) {
      return Future.delayed(Duration(milliseconds: 500), () {
        return push(widget);
      });
    } else {
      return navigatorKey.currentState!.push(MaterialPageRoute<Null>(builder: (BuildContext context) {
        return widget;
      }));
    }
  }

  static Future pushReplacement(Widget widget) async {
    if (navigatorKey.currentState == null) {
      return Future.delayed(Duration(milliseconds: 500), () {
        return pushReplacement(widget);
      });
    } else {
      return navigatorKey.currentState!.pushReplacement(MaterialPageRoute<Null>(builder: (BuildContext context) {
        return widget;
      }));
    }
  }

  static Future<bool> pop([bool? result]) {
    if (navigatorKey.currentState == null) {
      return Future.delayed(Duration(milliseconds: 500), () {
        return pop(result);
      });
    } else {
      navigatorKey.currentState!.pop(result);
      return Future.value(result);
    }
  }
}
