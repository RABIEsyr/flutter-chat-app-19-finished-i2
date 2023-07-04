import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skidrow_friend/providers/auth.dart';
import 'package:skidrow_friend/screens/auth_screen.dart';
import 'package:skidrow_friend/screens/splash_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:skidrow_friend/config/config.dart' as myUrl;

class MySocket {
  static late IO.Socket socket;

  static String toko = '';

  void connectMySocket() async {
    var prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('apiKey')!);
    var token = extractedUserData['token'];
    toko = token;
    socket = IO.io(myUrl.url,
        // IO.OptionBuilder()
        // .setTransports(['websocket'])
        //  .disableAutoConnect()
        //  .setExtraHeaders({'token': "$token"})
        //  .setQuery({'token': token})
        // //  .enableForceNewConnection()
        //  .build()
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
        });
    socket.connect();
    socket.emit('eventa', toko);
  }

  static void sendDataSocket(String token) {
    // final Map<String, String> packet = Map();
    socket.emit('eventa', toko);
  }

  MySocket() {
    connectMySocket();
  }
}

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;
  var poo;
  final String to;
  SocketClient({required this.to}) {}

  SocketClient._internal(this.to) {
    print('poo' + '$poo');
    socket = IO.io(
        myUrl.url,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders({'token': "$to"})
            .setQuery({'token': to})
            //  .enableForceNewConnection()
            .build());
    socket!.connect();
    socket!.on('connect', (_) {});
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal('');
    return _instance!;
  }
}

class SocketServices with ChangeNotifier {
  IO.Socket? socket;
  final BuildContext ctx;
  BuildContext? context;

  SocketServices({required this.ctx});

  SocketServices getInstance() {
    return SocketServices(ctx: ctx);
  }

  connectSocket() async {
    var prefs = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(prefs.getString('apiKey')!);
    var userId = extractedUserData['userId'];
    socket = IO.io(
      myUrl.url,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'query': {'userId': userId}
      },
    );

    socket?.connect();

    socket?.on('sss', (data) {
      print(data);
      onClick(
        'payload',
      );
    });
  }

 void onClick(String payload) {
    // Navigator.of(context!).pushNamed(Testo.routeName);
  }

  void sendSocketRequest({required String token, required String message, required String toUserId}) {
    Map<String, dynamic> messageBundle = {'token': token, 'message': message, 'toUserId': toUserId};
    final messageBundleJson = json.encode(messageBundle);
    
    // socket?.emit(
    //   'new-frien-request',
    //   messageBundleJson,
    // );
    socket?.emit(
      '2new-frien-request',
      messageBundleJson,
    );
  }
}
