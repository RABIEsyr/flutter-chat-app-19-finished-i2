import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:skidrow_friend/config/config.dart' as myUrl;
import 'package:skidrow_friend/crypto/encrypt_decrypt.dart';
import 'package:skidrow_friend/providers/auth.dart';
import 'package:http/http.dart' as http;

class RequestMessage with ChangeNotifier {
  Future<void> repeatRequesMessage({
    required String token,
    required BuildContext context,
    required String publicKey,
    required String message,
    required String userId,
  }) async {
    var url = Uri.parse('${myUrl.url}/request-users/repeat-request');

    var myHeaders = {
      'Content-Type': 'application/json',
      'authorization': token
    };

    final encrypto = Crypto();
    Auth authService = Provider.of<Auth>(context, listen: false);

    var messageTo = encrypto.encryptMessageTo(
      publicKeyX: publicKey,
      message: message,
    );
    var messageFrom = encrypto.encryptMessageFrom(
      myPublicKey: authService.publicKeyFromServer!,
      message: message,
    );

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
      print('all_user repeat-request ${res}');
      if (res['success'] == true) {}

      notifyListeners();
    } catch (e) {
      print('err007 ${e}');
    }
  }
}
