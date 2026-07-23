import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Prepare timezone database (needed for scheduling)
    // tz.initializeTimeZones();
    // 2. Android init — points to the status-bar icon
    const androidSettings = AndroidInitializationSettings('ic_notification');
    // 3. iOS/macOS init
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      // we ask later, explicitly
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    // 4. Initialize + wire up the tap handler
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final raw = response.payload;
        if (raw == null || raw.isEmpty) return;
        // Decode the JSON string back into a Map
        final Map<String, dynamic> data = jsonDecode(raw);
        print('notification payload:::::: $data');
      },
    );
  }

  Future<bool> requestPermissions() async {
    // ----- Android 13+ -----
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted = await androidImpl?.requestNotificationsPermission();
    // ----- iOS -----
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = await iosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return (androidGranted ?? iosGranted) ?? false;
  }

  Future<void> showBasicNotification() async {
    // 1. Android-specific look & behavior
    const androidDetails = AndroidNotificationDetails(
      'basic_channel',
      // channel id (must be unique)
      'Basic Notifications',
      // channel name (shown in settings)
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
      // icon: 'ic_notification',
    );
    // 2. iOS-specific look
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    // 3. Combine into one details object
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    // 4. Fire it!
    await _plugin.show(
      id: 0,
      // notification id
      title: 'Hello 👋',
      // title
      body: 'Your first local notification!',
      // body
      notificationDetails: details,
      payload: jsonEncode({'data': 'home_screen'}),
      // optional data for the tap handler
    );
  }
}
