import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:platform/platform.dart';

class UMessageAuthorizationOptions {
  static const int None = 0;
  static const int Badge = (1 << 0);
  static const int Sound = (1 << 1);
  static const int Alert = (1 << 2);
//  static const int CarPlay = (1 << 3);
//  static const int CriticalAlert = (1 << 4); // AVAILABLE_IOS(12.0)
//  static const int ProvidesAppNotificationSettings = (1 << 5); // AVAILABLE_IOS(12.0)
//  static const int Provisional = (1 << 6); // AVAILABLE_IOS(12.0)
//  static const int Announcement = (1 << 7); // AVAILABLE_IOS(13.0)
}

class UMeng {

  static final Platform _platform = LocalPlatform();
  static final String _tag = "| UMeng | Flutter | Plugin | ";

  static const String _method_setup = "setup";
  static const String _method_applyForPushAuthorization = "applyForPushAuthorization";

  static const MethodChannel _channel =
      const MethodChannel('umpush');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static void setup({
    @required String appKey,
    String channel,
    bool enabledLog = false,
  }) {
    print(_tag + "setup:");

    _channel.invokeMethod(_method_setup, {
      'appKey': appKey,
      'channel': channel,
      'enabledLog': enabledLog,
    });
  }

  static void applyForPushAuthorization(
      [int notificationTypes = (UMessageAuthorizationOptions.Badge | UMessageAuthorizationOptions.Sound | UMessageAuthorizationOptions.Alert)]) {
    print(_tag + "applyForPushAuthorization, notificationTypes: " + notificationTypes.toString());

    if (!_platform.isIOS) {
      return;
    }

    _channel.invokeMethod(_method_applyForPushAuthorization, notificationTypes);
  }

}
