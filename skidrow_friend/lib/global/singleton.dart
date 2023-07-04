import 'package:flutter/material.dart';

class Singleton {
  static final Singleton _singleton = Singleton._internal();

  final navigatorKey = GlobalKey<NavigatorState>();

  factory Singleton() {
    return _singleton;
  }

  Singleton._internal();

  showMyDialog() {
    Future.delayed(
      const Duration(seconds: 0),
      () => showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('Fireabse Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('There is a server error, please try again later.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
