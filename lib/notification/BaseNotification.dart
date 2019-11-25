import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sentora_base/notification/ReceivedNotification.dart';

class BaseNotification {
  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static StreamController<ReceivedNotification> _didReceiveLocalNotificationController;
  static StreamController<String> _selectNotificationController;
  static bool _initialized = false;

  static AndroidNotificationDetails andDetails = AndroidNotificationDetails(
      'TR_COM_SENTORA_CHANNEL_ID', 'TR_COM_SENTORA_CHANNEL_NAME', 'TR_COM_SENTORA_CHANNEL',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  static IOSNotificationDetails iosDetails = IOSNotificationDetails();
  static NotificationDetails nDetails = NotificationDetails(andDetails, iosDetails);

  //TODO android/app/src/main/res/drawable/app_icon.png eklenmeli. !! Bunu assert ile var mı diye bakabilirsin.
  /// Android icin
  ///
  /// <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
  ///
  /// <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  //      <intent-filter>
  //      <action android:name="android.intent.action.BOOT_COMPLETED"></action>
  //      </intent-filter>
  //  </receiver>
  ///
  /// <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
  ///
  /// <uses-permission android:name="android.permission.VIBRATE" />
  ///
  /// Proguard dosyasinda
  ///
  /// -keep class com.dexterous.** { *; }
  static Future<void> init(Function(ReceivedNotification) receiveFun, Function(String) payloadFun) async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _didReceiveLocalNotificationController = StreamController<ReceivedNotification>();
    _selectNotificationController = StreamController<String>();

    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {
          _didReceiveLocalNotificationController.add(ReceivedNotification(id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: (String payload) async {
          if (payload != null) {
            debugPrint('notification payload: ' + payload);
          }
          _selectNotificationController.add(payload);
        });

    _initialized = true;

    _didReceiveLocalNotificationController.stream.listen((ReceivedNotification receivedNotification) async {
      receiveFun(receivedNotification);
    });
    _selectNotificationController.stream.listen((String payload) async {
      payloadFun(payload);
    });
  }

  static Future<void> newNotification(int id, String title, String body, {Time time, RepeatInterval interval, String payload}) async {
    if(!_initialized) {
      print('call init method first!!!');
      return;
    }

    await _flutterLocalNotificationsPlugin.cancel(id);
    if(time != null) {
      await _flutterLocalNotificationsPlugin.showDailyAtTime(id, title, body, time, nDetails, payload: payload);
    } else if(interval != null) {
      await _flutterLocalNotificationsPlugin.periodicallyShow(id, title, body, interval, nDetails, payload: payload);
    } else {
      await _flutterLocalNotificationsPlugin.show(id, title, body, nDetails, payload: payload);
    }
  }

  static Future<void> cancelNotification(int id) async {
    if(!_initialized) {
      print('call init method first!!!');
      return;
    }

    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    if(!_initialized) {
      print('call init method first!!!');
      return;
    }

    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> dispose() async{
    if(!_initialized) {
      return;
    }
    await _selectNotificationController.close();
    await _didReceiveLocalNotificationController.close();
  }
}