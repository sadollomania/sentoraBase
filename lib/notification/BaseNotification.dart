import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sentora_base/notification/ReceivedNotification.dart';
import 'package:synchronized/synchronized.dart';
import 'package:timezone/standalone.dart';

class BaseNotification {
  static RepeatInterval intervalEveryMinute = RepeatInterval.everyMinute;
  static RepeatInterval intervalHourly = RepeatInterval.hourly;
  static RepeatInterval intervalDaily = RepeatInterval.daily;
  static RepeatInterval intervalWeekly = RepeatInterval.weekly;
  static Lock lock = Lock();

  static Time contructNotificationTime(int hour, int minute, int second) {
    return Time(hour, minute, second);
  }

  static late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  static late StreamController<ReceivedNotification> _didReceiveLocalNotificationController;
  static late StreamController<String> _selectNotificationController;
  static bool _initialized = false;


  static AndroidNotificationDetails andDetails = AndroidNotificationDetails(
      'TR_COM_SENTORA_NOTIFICATION_ID', 'TR_COM_SENTORA_NOTIFICATION_NAME',
      channelDescription: 'TR_COM_SENTORA_NOTIFICATION_CHANNEL',
      importance: Importance.max, priority: Priority.high, ticker: 'ticker');
  static IOSNotificationDetails iosDetails = IOSNotificationDetails();
  static MacOSNotificationDetails macOSDetails = MacOSNotificationDetails();
  static NotificationDetails nDetails = NotificationDetails(android: andDetails, iOS: iosDetails, macOS: macOSDetails);

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
  static Future<void> init(Function(ReceivedNotification)? receiveFun, Function(String)? payloadFun) async {
    await lock.synchronized(() async {
      if(!_initialized) {
        _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        _didReceiveLocalNotificationController = StreamController<ReceivedNotification>();
        _selectNotificationController = StreamController<String>();

        var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
        var initializationSettingsIOS = IOSInitializationSettings(
            onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
              _didReceiveLocalNotificationController.add(ReceivedNotification(id: id, title: title ?? "", body: body ?? "", payload: payload ?? ""));
            });
        var initializationSettingsMacOS = MacOSInitializationSettings();
        var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS, macOS: initializationSettingsMacOS);
        await _flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
            onSelectNotification: (String? payload) async {
              if (payload != null) {
                debugPrint('notification payload: ' + payload);
              }
              _selectNotificationController.add(payload ?? "");
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

  static Future<void> newNotification(int id, String title, String body, {Time? time, RepeatInterval? interval, String? payload}) async {
    if(!_initialized) {
      debugPrint('call init method first!!!');
      return;
    }

    await _flutterLocalNotificationsPlugin.cancel(id);
    if(interval != null) {
      switch(interval) {
        case RepeatInterval.everyMinute:
        case RepeatInterval.hourly:
        case RepeatInterval.weekly:
          await _flutterLocalNotificationsPlugin.periodicallyShow(id, title, body, interval, nDetails, payload: payload);
          break;
        case RepeatInterval.daily:
          if(time != null) {
            DateTime now = DateTime.now();
            DateTime dt = DateTime(now.year, now.month, now.day, time.hour, time.minute, time.second);
            TZDateTime tzdt = TZDateTime.from(dt, TZDateTime.local(2022).location);
            await _flutterLocalNotificationsPlugin.zonedSchedule(id, title, body, tzdt, nDetails, payload: payload, androidAllowWhileIdle: true, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.time);
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
        TZDateTime tzdt = TZDateTime.from(dt, TZDateTime.local(2022).location);
        await _flutterLocalNotificationsPlugin.zonedSchedule(id, title, body, tzdt, nDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true, payload: payload);
      } else {
        await _flutterLocalNotificationsPlugin.show(id, title, body, nDetails, payload: payload);
      }
    }
  }

  static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledDate, {String? payload}) async {
    if(!_initialized) {
      debugPrint('call init method first!!!');
      return;
    }

    await _flutterLocalNotificationsPlugin.cancel(id);
    TZDateTime tzdt = TZDateTime.from(scheduledDate, TZDateTime.local(2022).location);
    await _flutterLocalNotificationsPlugin.zonedSchedule(id, title, body, tzdt, nDetails, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true, payload: payload);
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