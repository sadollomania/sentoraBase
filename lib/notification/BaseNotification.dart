import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sentora_base/notification/ReceivedNotification.dart';
import 'package:synchronized/synchronized.dart';

class BaseNotification {
  static RepeatInterval intervalEveryMinute = RepeatInterval.EveryMinute;
  static RepeatInterval intervalHourly = RepeatInterval.Hourly;
  static RepeatInterval intervalDaily = RepeatInterval.Daily;
  static RepeatInterval intervalWeekly = RepeatInterval.Weekly;
  static Lock lock = Lock();

  static Time contructNotificationTime(int hour, int minute, int second) {
    return Time(hour, minute, second);
  }

  static FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static StreamController<ReceivedNotification> _didReceiveLocalNotificationController;
  static StreamController<String> _selectNotificationController;
  static bool _initialized = false;


  static AndroidNotificationDetails andDetails = AndroidNotificationDetails(
      'TR_COM_SENTORA_NOTIFICATION_ID', 'TR_COM_SENTORA_NOTIFICATION_NAME', 'TR_COM_SENTORA_NOTIFICATION_CHANNEL',
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
    await lock.synchronized(() async {
      if(!_initialized) {
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

        if(receiveFun != null) {
          _didReceiveLocalNotificationController.stream.listen((ReceivedNotification receivedNotification) async {
            receiveFun(receivedNotification);
          });
        }
        if(payloadFun != null) {
          _selectNotificationController.stream.listen((String payload) async {
            payloadFun(payload);
          });
        }

        _initialized = true;
      }
    });
  }

  static Future<List<PendingNotificationRequest>> getPendingRequests() {
    return _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  static Future<void> newNotification(int id, String title, String body, {Time time, RepeatInterval interval, String payload}) async {
    if(!_initialized) {
      debugPrint('call init method first!!!');
      return;
    }

    await _flutterLocalNotificationsPlugin.cancel(id);
    if(interval != null) {
      switch(interval) {
        case RepeatInterval.EveryMinute:
        case RepeatInterval.Hourly:
        case RepeatInterval.Weekly:
          await _flutterLocalNotificationsPlugin.periodicallyShow(id, title, body, interval, nDetails, payload: payload);
          break;
        case RepeatInterval.Daily:
          if(time != null) {
            await _flutterLocalNotificationsPlugin.showDailyAtTime(id, title, body, time, nDetails, payload: payload);
          } else {
            await _flutterLocalNotificationsPlugin.periodicallyShow(id, title, body, interval, nDetails, payload: payload);
          }
          break;
      }
    } else {
      if(time != null) {
        DateTime now = DateTime.now();
        DateTime dt = DateTime(now.year, now.month, now.day, time.hour, time.minute, time.second);
        if(dt.isBefore(now)) {
          dt.add(Duration(days: 1));
        }
        await _flutterLocalNotificationsPlugin.schedule(id, title, body, dt, nDetails, payload: payload, androidAllowWhileIdle: true);
      } else {
        await _flutterLocalNotificationsPlugin.show(id, title, body, nDetails, payload: payload);
      }
    }
  }

  static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledDate, {String payload}) async {
    if(!_initialized) {
      debugPrint('call init method first!!!');
      return;
    }

    await _flutterLocalNotificationsPlugin.cancel(id);
    await _flutterLocalNotificationsPlugin.schedule(id, title, body, scheduledDate, nDetails, payload: payload, androidAllowWhileIdle: true);
  }

  static Future<void> cancelNotification(int id) async {
    if(!_initialized) {
      debugPrint('call init method first!!!');
      return;
    }

    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    if(!_initialized) {
      debugPrint('call init method first!!!');
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