import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:umpush/umpush.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await UMeng.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              FlatButton(
                child: Text('setup'),
                onPressed: () {
                  UMeng.setup(appKey: "5ec1030d0cafb22cd000006b", channel: "App Store", enabledLog: true);
                },
              ),
              FlatButton(
                child: Text('applyForPushAuthorization'),
                onPressed: () {
                  UMeng.applyForPushAuthorization(UMessageAuthorizationOptions.Sound | UMessageAuthorizationOptions.Badge | UMessageAuthorizationOptions.Alert);
                },
              ),

            ],
          )
        ),
      ),
    );
  }
}
