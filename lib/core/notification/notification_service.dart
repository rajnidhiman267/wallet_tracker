import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static bool _permissionRequested = false;

  Future<void> init() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    if (!_permissionRequested) {
      _permissionRequested = true;

      await messaging.requestPermission();
    }

    String? token = await messaging.getToken();

    log("TOKEN: $token");

    FirebaseMessaging.onMessage.listen((message) {
      log(message.notification?.title ?? "");
    });
  }
}
