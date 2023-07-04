import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart' as ctt;
import 'package:encrypt/encrypt.dart' as ee;

import 'package:skidrow_friend/config/config.dart' as myUrl;
import 'package:skidrow_friend/model/rsa.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expairyDate;
  String? _userId;
  Timer? _authTimer;
  String? _refreshToken;
  int timeToExpiry = 6;
  bool _isConnectToserver = true;


  bool get isConnectToserver => _isConnectToserver;

  bool _usernameExists = false;

  bool get usernameExists => _usernameExists;

  bool get isAuth {
    return _token != null;
  }

  String? _clientPass;

  String? get token {
    // if (_expairyDate != null &&
    //     _expairyDate!.isAfter(DateTime.now()) &&
    //     _token != null) {
    //   return _token;
    // }
    if (_token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  String? _publicKeyFromServer;
  String? _privateKeyEncryptedFromServer;
  String? get publicKeyFromServer {
    return _publicKeyFromServer;
  }
  String? get privateKeyEncryptedFromServer {
    return _privateKeyEncryptedFromServer;
  }

  bool? _isFriend = false;
  bool? get isFriend {
    return _isFriend;
  }

  String? decryptedPrivateKeyAfterLogin;

  void checkIsFriend({required String userId, required String token,}) async{
    var url = Uri.parse('${myUrl.url}/request-users/is-friend');

    var myHeaders = {
      'Content-Type': 'application/json',
      'authorization': token
    };

    Map<String, dynamic> body = {
      'userId': userId,
    };
    var bodyToUserId = json.encode(body);
    try {    
      final response =
          await http.post(url, headers: myHeaders, body: bodyToUserId);

          var res = json.decode(response.body);
      if(res['friend']) {
         _isFriend = true;
      } else {
        _isFriend = false;
      }
      notifyListeners();
    } catch(e) {
      print(e);
      throw e;
    }
  }

  Future<void> setAsFriend({
    required String userId,
    required String token,
  }) async {
    var url = Uri.parse('${myUrl.url}/request-users/set-as-friend');

    var myHeaders = {
      'Content-Type': 'application/json',
      'authorization': token
    };

    Map<String, dynamic> body = {
      'userId': userId,
    };
    var bodyToUserId = json.encode(body);
    try {    
      final response =
          await http.post(url, headers: myHeaders, body: bodyToUserId);

          var res = json.decode(response.body);
      if(res['success']) {
         _isFriend = true;
         notifyListeners();
      } else {
        _isFriend = false;
      }
      notifyListeners();
    } catch(e) {
      print(e);
      throw e;
    }
  }

  Future<void> _authenticate (
      String username, String password, String urlSegment, [province, gender]) async {
         final prefs = await SharedPreferences.getInstance();
         var firebaseToken = prefs.getString('firebaseToken');
         if (firebaseToken == null)
        firebaseToken = 'ss';
    var url = Uri.parse('${myUrl.url}/auth/$urlSegment');
    final dividePassword = hashPassword(password);
    var toServer = dividePassword[1];
    var toClient = dividePassword[0];
    Map<String, dynamic> credentials = {
      'username': username,
      'password': toServer,
      'firebaseToken': firebaseToken
    };
    var body = json.encode(credentials);

    dynamic rsaKeys = await Rsa().generateKeysNew();

    String publicKey = rsaKeys['public-key'];
    String privateKey = rsaKeys['private-key'];


   var fixPass = fixClientPasswordLength(toClient);
   final privateKeyEncrypted = encryptPrivateKey(fixPass, privateKey); //[f638e2789006da9bb337fd5, 89e37a265a70f359]
 
    // final ss2 = decryptPrivateKey(fixPass, privateKeyEncrypted);
    
    String? deviceFirebaseToken = SetFirebaseToken.firebaseToken;

    if (deviceFirebaseToken == null) {
      deviceFirebaseToken = 's';
    }
    print('tokenF $deviceFirebaseToken');
  
    Map<String, dynamic> credentialsSignup = {
      'username': username,
      'password': toServer,
      'province': province,
      'gender': gender,
      'firebaseToken': deviceFirebaseToken,
      'publicKey': publicKey,
      'privateKeyEncrypted': privateKeyEncrypted
    };
    var bodySignup = json.encode(credentialsSignup);

    const myHeaders = {'Content-Type': 'application/json'};
    try {
      final response = 
      urlSegment == 'login' 
      ? await http.post(url, headers: myHeaders, body: body)
      : await http.post(url, headers: myHeaders, body: bodySignup);
      final responseData = json.decode(response.body);
      print('responso $responseData');
      if (responseData['success']) {
        _token = responseData['token'];
        _userId = responseData['userId'];
        _refreshToken = responseData['refreshToken'];
        _expairyDate = DateTime.now().add(
          Duration(
            seconds: int.parse(responseData['expireIn']),
          ),
        );
        _publicKeyFromServer = responseData['publicKey'];
        _privateKeyEncryptedFromServer = responseData['encryptedPrivateKey'];

        final prefs = await SharedPreferences.getInstance();
      final decryptedPrivateKey = decryptPrivateKey(fixPass, _privateKeyEncryptedFromServer!);
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expairyDate!.toIso8601String(),
        'refreshToken': _refreshToken,
        'clientPassword': toClient,
        'publicKey': _publicKeyFromServer,
        'privateKey': decryptedPrivateKey
      });

      
      await prefs.setString('apiKey', userData);
       final prefs2 = await SharedPreferences.getInstance();
      var rr = json.decode(prefs2.getString('apiKey')!);
      //  _autoLogout();

      final aaa = await SharedPreferences.getInstance();
       _usernameExists = false;
      notifyListeners();
      }
      if (!responseData['success']) {
        print('notSuccess');
        _usernameExists = true;
        notifyListeners();
      }
      // print(_expairyDate);

      
    } catch (e) {
      throw e;
    }
  }

  Future<void> signup(
      {required String username, required String password, required String province, required String gender}) async {
    return _authenticate(username, password, 'signup', province, gender);
  }

  Future<void> login(
      {required String username, required String password}) async {
    return _authenticate(username, password, 'login');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('apiKey')) return false;

    final extractedUserData = json.decode(prefs.getString('apiKey')!);
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    // if (expiryDate.isBefore(DateTime.now())) {
    //   return false;
    // }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _refreshToken = extractedUserData['refreshToken'];
    _expairyDate = expiryDate;
    _publicKeyFromServer = extractedUserData['publicKey'];
    _privateKeyEncryptedFromServer = extractedUserData['privateKey'];
    _clientPass = extractedUserData['clientPassword'];

    // print('cdf, $_privateKeyEncryptedFromServer');
    notifyListeners();
    //  _autoLogout();

    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _refreshToken = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('apiKey');

    notifyListeners();
  }

  String getTokenTest() {
    return _token!;
  }

  // void _autoLogout() async {
  //   if (_authTimer != null) _authTimer!.cancel();

  //   timeToExpiry = _expairyDate!.difference(DateTime.now()).inSeconds;
  //   // _authTimer = Timer(Duration(seconds: timeToExpiry), aa);
  //   if (_refreshToken != null) {
  //     Timer.periodic(const Duration(minutes: 150), (t) async {
  //       final prefs = await SharedPreferences.getInstance();
  //       var url = Uri.parse('${myUrl.url}/refresh-token/');
  //       if (prefs.getString('apiKey') != null) {
  //         final extractedUserData = json.decode(prefs.getString('apiKey')!);
  //         String? refreshToken = extractedUserData['refreshToken'];
  //         Map<String, String?> credentials = {
  //           'refreshToken': refreshToken,
  //         };
  //         const myHeaders = {'Content-Type': 'application/json'};
  //         var body = json.encode(credentials);
  //         try {
  //           _isConnectToserver = true;
  //           var data = await http.post(url, headers: myHeaders, body: body);
            
  //           if (data.statusCode == 200) {
  //             final responseData = json.decode(data.body);
  //                 if (responseData['error'] == true) {  
  //                   Future.delayed(Duration.zero, logout);
  //               }
                
                
  //             if (responseData['success'] == true) {
  //                print('123, $token');
  //               print('1234, $_userId');
  //               print('1235, $token');
  //               // print('1236, $decryptedPrivateKey');
                
  //               _isConnectToserver = true;
                
  //               _token = responseData['token'];
  //               _userId = responseData['userId'];
  //               _refreshToken = responseData['refreshToken'];
  //               _privateKeyEncryptedFromServer = responseData['privateKey'];
  //               String toClient2 = extractedUserData['clientPassword'];
  //               var fixPass = fixClientPasswordLength(toClient2);
  //               print('1237, $toClient2');
  //               final decryptedPrivateKey = decryptPrivateKey(fixPass, _privateKeyEncryptedFromServer!);
               
               
  //               final userData = json.encode({
  //                 'token': _token,
  //                 'userId': _userId,
  //                 'expiryDate': _expairyDate!.toIso8601String(),
  //                 'refreshToken': _refreshToken,
  //                 'publicKey': _publicKeyFromServer,
  //                 'privateKey': decryptedPrivateKey,
  //                 'clientPassword': toClient2
  //               });
               
  //               await prefs.setString('apiKey', userData);
  //               timeToExpiry += 60;
  //               notifyListeners();
  //             }
  //           } else {
  //             print('999');
  //           }
  //         } catch (e) {
  //           print('the error is ${e}');
  //           _isConnectToserver = false;
  //           notifyListeners();
  //           print('error in network');
  //         }
  //       }
  //     });
  //   }
  // }


 void checkAuth() async {
  
      print('dodo');
        final prefs = await SharedPreferences.getInstance();
        var url = Uri.parse('${myUrl.url}/refresh-token/');
        if (prefs.getString('apiKey') != null) {
          final extractedUserData = json.decode(prefs.getString('apiKey')!);
          String? refreshToken = extractedUserData['refreshToken'];
          Map<String, String?> credentials = {
            'refreshToken': refreshToken,
          };
          const myHeaders = {'Content-Type': 'application/json'};
          var body = json.encode(credentials);
          try {
            _isConnectToserver = true;
            var data = await http.post(url, headers: myHeaders, body: body);
            
            if (data.statusCode == 200) {
              final responseData = json.decode(data.body);
                  if (responseData['error'] == true) {  
                    Future.delayed(Duration.zero, logout);
                }
                
                
              if (responseData['success'] == true) {
                 print('123, $token');
                print('1234, $_userId');
                print('1235, $token');
                // print('1236, $decryptedPrivateKey');
                
                _isConnectToserver = true;
                
                _token = responseData['token'];
                _userId = responseData['userId'];
                _refreshToken = responseData['refreshToken'];
                _privateKeyEncryptedFromServer = responseData['privateKey'];
                String toClient2 = extractedUserData['clientPassword'];
                var fixPass = fixClientPasswordLength(toClient2);
                print('1237, $toClient2');
                final decryptedPrivateKey = decryptPrivateKey(fixPass, _privateKeyEncryptedFromServer!);
               
               
                final userData = json.encode({
                  'token': _token,
                  'userId': _userId,
                  'expiryDate': _expairyDate!.toIso8601String(),
                  'refreshToken': _refreshToken,
                  'publicKey': _publicKeyFromServer,
                  'privateKey': decryptedPrivateKey,
                  'clientPassword': toClient2
                });
               
                await prefs.setString('apiKey', userData);
                timeToExpiry += 60;
                notifyListeners();
              }
            } else {
              print('999');
            }
          } catch (e) {
            print('the error is ${e}');
            _isConnectToserver = false;
            notifyListeners();
            print('error in network');
          }
        }
      
    
  }

static List<String> hashPassword(String password) {
  var bytes = utf8.encode(password); 
    var digest = ctt.sha1.convert(bytes).toString();
    List<String> dividedhashPassword = [];
    dividedhashPassword.add(digest.substring(0, 23));
    dividedhashPassword.add(digest.substring(24, 40));
    print(dividedhashPassword);

    return dividedhashPassword;
}


String encryptPrivateKey(String key, String privateKey) {
  ee.Encrypted encrypted = encryptWithAES(key, privateKey);
  String encryptedBase64 = encrypted.base64;

 return encryptedBase64;
}

String decryptPrivateKey(String key, String encryptedPrivateKey) {
  final cipherKey = ee.Key.fromUtf8(key);
  final encryptService = ee.Encrypter(
      ee.AES(cipherKey, mode: ee.AESMode.cbc)); 
  final initVector = ee.IV.fromUtf8(key.substring(0,
      16));


  return encryptService.decrypt(ee.Encrypted.fromBase64(encryptedPrivateKey), iv: initVector);
}

///Encrypts the given plainText using the key. Returns encrypted data
ee.Encrypted encryptWithAES(String key, String plainText) {
  final cipherKey = ee.Key.fromUtf8(key);
  final encryptService = ee.Encrypter(ee.AES(cipherKey, mode: ee.AESMode.cbc));
  final initVector = ee.IV.fromUtf8(key.substring(0,
      16)); //Here the IV is generated from key. This is for example only. Use some other text or random data as IV for better security.

  ee.Encrypted encryptedData =
      encryptService.encrypt(plainText, iv: initVector);
  return encryptedData;
}


String fixClientPasswordLength(String pass) {
  final length = pass.length;

  if (length > 16) {
    final newStr = pass.substring(0, 16);
    return newStr;
  } else {
    int nlength = length;
    String addToPass = pass;
    while (nlength <= 16) {
      addToPass = addToPass + '0';
      nlength++;
    }
    return addToPass;
  }
}
}

class SetFirebaseToken {
  static String? firebaseToken;
}
