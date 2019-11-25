import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationTaskConfig {
  final int id;
  final String title;
  final String body;
  final Time time;
  final RepeatInterval interval;
  final String payload;
  NotificationTaskConfig(
    this.id,
    this.title,
    this.body,
      {this.time,
    this.interval,
    this.payload,
  }) : assert(id != null),
        assert(title != null),
        assert(body != null);
}