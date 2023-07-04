import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skidrow_friend/config/config.dart' as myUrl;
import 'package:skidrow_friend/crypto/encrypt_decrypt.dart';
import 'package:skidrow_friend/providers/auth.dart';

class MessageRepo with ChangeNotifier {
  List<Message> _messages = List.filled(0, Message());

  List<Message> get messages => _messages;

  bool? _isShouldScroll;

  bool? get isShouldScroll => _isShouldScroll;

  Future<void> getAllMessages(
      {required String token, required String userId}) async {
    var url = Uri.parse('${myUrl.url}/messages/get-messages');
    var myHeaders = {
      'Content-Type': 'application/json',
      'authorization': token
    };
    Map<String, String> body = {'userId': userId};
    var bodyUserId = json.encode(body);

    try {
      final response =
          await http.post(url, headers: myHeaders, body: bodyUserId);
      // print('reso is, ${response.body}');
      var res = json.decode(response.body) as List;
      var res2 = res.map((message) => Message.fromJson(message)).toList();
      _messages  = res2;
      notifyListeners();
    } catch (e) {
      print('message error, $e');
      rethrow;
    }
  }

  Future<bool> repeatRequest({required String token, required String userId, required String message, required String recieverPublicKey, required BuildContext context}) async{
    var url = Uri.parse('${myUrl.url}/request-users/repeat-request');
    var myHeaders = {
      'Content-Type': 'application/json',
      'authorization': token
    };

    final encrypto = Crypto();
    Auth authService = Provider.of<Auth>(context, listen: false);
    
    var messageTo = encrypto.encryptMessageTo(publicKeyX: recieverPublicKey, message: message);
    var messageFrom = encrypto.encryptMessageFrom(myPublicKey: authService.publicKeyFromServer!, message: message);

    Map<String, String> body = {
      'toUserId': userId,
      'toMessage': messageTo,
      'fromMessage': messageFrom,
    };
    var bodyUserId = json.encode(body);
    try {
      final response =
          await http.post(url, headers: myHeaders, body: bodyUserId);
      final res = json.decode(response.body);
      if (res['success']) {
        
       var newMsg = Message(fromId: Provider.of<Auth>(context, listen: false).userId, fromText: messageFrom);
        _messages.add(newMsg);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


  Future<bool> acceptFriendRequest({
    required String token,
    required String userId,
    required String message,
    required String recieverPublicKey,
    required BuildContext context,
  }) async {

    var url = Uri.parse('${myUrl.url}/request-users/set-as-friend');
    var myHeaders = {
      'Content-Type': 'application/json',
      'authorization': token
    };

    final encrypto = Crypto();
    Auth authService = Provider.of<Auth>(context, listen: false);
    
    var messageTo = encrypto.encryptMessageTo(publicKeyX: recieverPublicKey, message: message);
    var messageFrom = encrypto.encryptMessageFrom(myPublicKey: authService.publicKeyFromServer!, message: message);

    Map<String, String> body = {
      'toUserId': userId,
      'toMessage': messageTo,
      'fromMessage': messageFrom,
    };
    var bodyUserId = json.encode(body);

    try {
      final response =
          await http.post(url, headers: myHeaders, body: bodyUserId);
      final res = json.decode(response.body);
      if (res['success']) {
         var newMsg = Message(fromId: Provider.of<Auth>(context, listen: false).userId, fromText: messageFrom);
        Provider.of<Auth>(context, listen: false).setAsFriend(userId: userId, token: token); 
        _messages.add(newMsg);
        notifyListeners();
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void addToCurrentChatMessages({message, id}) async {
    // final prefs = await SharedPreferences.getInstance();
    // var extracted = json.decode(prefs.getString('apiKey')!);

    // String privateKey = extracted['privateKey']!;
    // final encrypto = Crypto();
  //  var msg = encrypto.decrypMessage(
  //     privateKey: privateKey,
  //     message: message,
  //   );
  var newMsg = Message(fromId: id, fromText: message, toText: message);
  _messages.add(newMsg);
  notifyListeners(); 

  }

  Future<void> resetMessageList() async {
    _messages = [];
    notifyListeners();
  }


  void setSCrollcontroller(bool scroll) {
    _isShouldScroll = scroll;
    notifyListeners();
  }
}

class Message {
  String? messageId;
  String? fromId;
  String? toId;
  String? fromText;
  String? toText;
  DateTime? messageDate;
  bool? isReaded;

  Message(
      {this.messageId,
      this.fromId,
      this.toId,
      this.fromText,
      this.toText,
      this.messageDate,
      this.isReaded});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        messageId: json['_id'],
        fromId: json['from'],
        toId: json['to'],
        fromText: json['fromText'],
        toText: json['toText'],
        isReaded: json['isReaded'],
        messageDate: DateTime.parse(json['date']),
      );
}
