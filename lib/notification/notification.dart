import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('------------------------------------------------------------------');
  debugPrint('tapped notificationID: (${notificationResponse.id}) : '
      'actionId: ${notificationResponse.actionId}, '
      ' payload: ${notificationResponse.payload}, '
      'input: ${notificationResponse.input}, '
      'notificationResponseType: ${notificationResponse.notificationResponseType}');
}

class Notification {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// A notification action which triggers a url launch event
  static const String urlLaunchActionId = 'id_1';

  /// A notification action which triggers a App navigation event
  static const String navigationActionId = 'id_3';

  /// Defines a iOS/MacOS notification category for text input actions.
  static const String darwinNotificationCategoryText = 'textCategory';

  /// Defines a iOS/MacOS notification category for plain actions.
  static const String darwinNotificationCategoryPlain = 'plainCategory';

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb) {
      return;
    }
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

  init() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    await _configureLocalTimeZone();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final List<DarwinNotificationCategory> darwinNotificationCategories = <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'ios_1',
            'Ios 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
    ];
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
      notificationCategories: darwinNotificationCategories,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: //notificationTapBackground,
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  //点击通知回调事件
  void selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  Future<void> send(String title, String body, {int? notificationId, String? params}) async {
    // 构建描述
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'task_notification',
      '行程提醒',
      importance: Importance.max,
      priority: Priority.high,
      //icon: null,
      ticker: 'ticker',
    );
    var iosDetails = const DarwinNotificationDetails();
    var notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: iosDetails);

    flutterLocalNotificationsPlugin.show(
        notificationId ?? DateTime.now().millisecondsSinceEpoch >> 10, title, body, notificationDetails,
        payload: params);
  }

  void cleanNotification() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> scheduleNotification(int id, String? title, String? body, DateTime scheduledDate,
      {String? payload}) async {
    debugPrint('scheduleNotification: $id , date: $scheduledDate');
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        payload: payload,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_notification',
            '行程提醒',
            channelDescription: '於設定的提醒時間發出通知',
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> periodicNotification(int id, String? title, String? body, DateTime scheduledDate) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('spending_notification', '每日提醒', channelDescription: '每日提醒');
    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      '每日提醒',
      '提醒內容',
      RepeatInterval.daily,
      notificationDetails,
    );
  }

  void cancelNotification(int id, {String? tag}) {
    flutterLocalNotificationsPlugin.cancel(id, tag: tag);
    debugPrint('cancelNotification: $id');
  }
}

var notification = Notification();
