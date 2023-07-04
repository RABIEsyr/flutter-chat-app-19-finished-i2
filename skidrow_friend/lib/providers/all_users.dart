import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:skidrow_friend/config/config.dart' as myUrl;
import 'package:skidrow_friend/crypto/encrypt_decrypt.dart';
import 'package:skidrow_friend/providers/auth.dart';

class AllUsers with ChangeNotifier {
  String xProvince = 'all';

  List<User> _allUsers = List.filled(0, User());
  List<User> get allUsers => _allUsers;

  List<User> _incomingRequestUsers = List.filled(0, User());
  List<User> get incomingRequestUsers => _incomingRequestUsers;
  List<User> get outRequestUsers => _outRequestUsers;
  List<User> _outRequestUsers = List.filled(0, User());

  List<User> _friends =  List.filled(0, User());
  List<User> get friends => _friends;
  

  void getAllUsers(String token, String province) async {
    var url = Uri.parse('${myUrl.url}/users/all-users');
    var myHeaders = {
      'Content-Type': 'application/json',
      'authorization': token
    };

    Map<String, dynamic> body = {'province': province};
    var bodyProvince = json.encode(body);

    try {
      final response =
          await http.post(url, headers: myHeaders, body: bodyProvince);
      print('resres ${json.decode(response.body)}');
      var res = json.decode(response.body) as List;

      var res2 = res.map((u) => User.fromJson(u)).toList();
      //  print(res2[0].userId);

      _allUsers = res2;
      _allUsers.forEach((element) {
        print('element.username ${element.username}, element.publicKey ${element.publicKey}', );
      });
      print(res2);
      notifyListeners();
    } catch (e) {
      print(' error fetch users: $e');
    }
  }

  void getRequestUsers({required String status, required String token}) async{
    print('status $status');
    var url = Uri.parse('${myUrl.url}/request-users/$status');
    var myHeaders = {
      'Content-Type': 'application/json',
      'authorization': token
    };

    if (status == 'in') {
    try {
      final response =
          await http.get(url, headers: myHeaders);
      var res = json.decode(response.body) as List;
      var res2 = res.map((u) => User.fromJson(u)).toList();
      _incomingRequestUsers = res2;
      notifyListeners();
    } catch (e) {
      print('error fetch request');
    }
    } else {
      try {
      final response =
          await http.get(url, headers: myHeaders);
      var res = json.decode(response.body) as List;
      var res2 = res.map((u) => User.fromJson(u)).toList();
      res2.forEach((element) {
        print('xxx ${element.publicKey}');
        print('yyy ${element.userId}');
      });
      _outRequestUsers = res2;
      notifyListeners();
    } catch (e) {
      print('error fetch request');
    }
    }
  }

  Future<void> removeUserAfterSendRequest({required BuildContext context,required int index, String? userId, String token = '', required String publicKey, required String message}) async {
    // if (message  == '') return;
    
    final encrypto = Crypto();
    Auth authService = Provider.of<Auth>(context, listen: false);
    
    var messageTo = encrypto.encryptMessageTo(publicKeyX: publicKey, message: message);
    var messageFrom = encrypto.encryptMessageFrom(myPublicKey: authService.publicKeyFromServer!, message: message);
    

    // var orginalPlainText = encrypto.decrypMessage(privateKey: authService.privateKeyEncryptedFromServer!, message: messageFrom);
    // print('authService3Orginal $orginalPlainText');

    var url = Uri.parse('${myUrl.url}/request-users/new-request');
    
    var myHeaders = {
      'Content-Type': 'application/json',
      'authorization': token
    };

    Map<String, dynamic> body = {
      'toUserId': userId,
      'toMessage': messageTo,
      'fromMessage': messageFrom,
    };
    var bodyToUserId = json.encode(body);
    try {
 
      final response =
          await http.post(url, headers: myHeaders, body: bodyToUserId);
      var res = json.decode(response.body);
      print('all_user aaa ${res}');
      if(res['success']) {
        print('indexex $index');
         allUsers.removeAt(index);
         notifyListeners();
      }   
    } catch (e) {
      print('err33 ${e}');
    }
     
     
  }

  // void getOutgoingRquests({required String token}) async {
  //   var url = Uri.parse('${myUrl.url}/request-users/outgoing-requests');
  //   var myHeaders = {
  //     'Content-Type': 'application/json',
  //     'authorization': token
  //   };

  //   try {
  //     final response = await http.get(url, headers: myHeaders);
  //     var res = json.decode(response.body) as List;
  //      var res2 = res.map((u) => User.fromJson(u)).toList();
  //     _outgoingRequest = res2;
  //   } catch (e) {}

  //   notifyListeners();
  // }

  void getFriends({required BuildContext context}) async{
    var token = Provider.of<Auth>(context, listen: false).token!;
    var url = Uri.parse('${myUrl.url}/friends-users/get-friends');
    var myHeaders = {
      'Content-Type': 'application/json',
      'authorization': token
    };

    try {
      final response =
          await http.get(url, headers: myHeaders);
      var res = json.decode(response.body) as List;
      var res2 = res.map((u) => User.fromJson(u)).toList();
      _friends = res2;
      notifyListeners();
    } catch (e) {
      print('error fetch request');
    }
}
}

class User {
  String? userId;
  String? username;
  String? gender;
  String? province;
  String? publicKey;

  User({this.userId, this.username, this.gender, this.province, this.publicKey});

  factory User.fromJson(Map<String, dynamic> json) => User(
      userId: json['_id'],
      username: json['username'],
      gender: json['gender'],
      province: json['province'],
      publicKey: json['publicKey']);
      
}
