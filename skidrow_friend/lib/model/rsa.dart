import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:skidrow_friend/config/config.dart' as myUrl;
import 'package:encrypt/encrypt.dart';

class Rsa {
  late RsaKeyHelper helper;
  static String? publicKey;

  Rsa() {
    helper = RsaKeyHelper();
  }

  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      getKeyPair() {
    return helper.computeRSAKeyPair(helper.getSecureRandom());
  }


  Future<void> generateKeys() async {
    crypto.AsymmetricKeyPair keyPair = await getKeyPair();
    dynamic prk = keyPair.privateKey;
    dynamic pbk = keyPair.publicKey;
    dynamic prkS = helper.encodePrivateKeyToPemPKCS1(prk);
    dynamic pbkS = helper.encodePublicKeyToPemPKCS1(pbk);

    // log(pbkS);
    // log(prkS);
    
  // do something with the file.
    dynamic npbk = helper.parsePublicKeyFromPem(pbkS);
    dynamic nprk = helper.parsePrivateKeyFromPem(prkS);

    publicKey = pbkS;

    final RsaKey = json.encode({'private-key': prkS, 'public-key': pbkS});
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('rsaKey', RsaKey);

    // demo
    // var publickey =
    //     '-----BEGIN RSA PUBLIC KEY----- MIIBCgKCAQEAg5SO7Z+Gsgf4qCb7dZuJFDoZ+WG4J1jJ8tpuMC2uylW4Q4bQSqDMYgv0zpAx4KACfbhikrmM/iASDXJayd/MJYVI62fv4wmXTdO4aSiVmajGhxeQ2nTltnKNS/vClUfSbNj+5POEeT1vLklEcs3/j32Ebewd6azZxnB2lbG0fixuto57iPPuXQOlCaLr1tLfr8PRFwBXgIhvUcnXZz+8Svcyz5enjkJ/4//feyvSL41dGWCdCxFCVcOqrtDshSYV6qjBEb1xsWBAp/HlZb31rplZQUZT0JtQSZBlY5n4SCiDT1zhe57IucU2VIbnp2cgFzIviiVmD5ZGZoy7vWWW+QIDAQAB -----END RSA PUBLIC KEY-----';
    // var txt = 'hello there';
    // var npbk22 = helper.parsePublicKeyFromPem(publickey);
    // var tt = encrypt(txt, npbk22);
    // print('XXX + $tt');
    // var privatekey10 =
    //     '-----BEGIN RSA PRIVATE KEY-----MIIFoQIBAAKCAQEAg5SO7Z+Gsgf4qCb7dZuJFDoZ+WG4J1jJ8tpuMC2uylW4Q4bQSqDMYgv0zpAx4KACfbhikrmM/iASDXJayd/MJYVI62fv4wmXTdO4aSiVmajGhxeQ2nTltnKNS/vClUfSbNj+5POEeT1vLklEcs3/j32Ebewd6azZxnB2lbG0fixuto57iPPuXQOlCaLr1tLfr8PRFwBXgIhvUcnXZz+8Svcyz5enjkJ/4//feyvSL41dGWCdCxFCVcOqrtDshSYV6qjBEb1xsWBAp/HlZb31rplZQUZT0JtQSZBlY5n4SCiDT1zhe57IucU2VIbnp2cgFzIviiVmD5ZGZoy7vWWW+QKCAQBN3JH7YSP2o6rr7i1s+b3TH1KRdNbhSbQvJjx/+/hruO/R3avSDXcEKekSdtddAbKXrI2AH5akJlwoYtwAi5MlPMraqmWUpu9G2ZtNdvuXsvzPog1QiE4KeZzNMsyBQ7/sMzgaSVPB3q206Rw9B1NMGM1NsqQ8y9EOkSxLBp407sGT0JZN5D2IZp35B9UkDrRvcoM4BhKrmL94yq8YgEsTgdLatebPATlAxdLP7D+0eAf2t1qB1gr6iFalXJOuADHx56TLkQ1qOmunLlPjW1cRavtb9pkbzbiUgoWOhBjtXZQmEX6tS+DKJ1TfklDCEXdaUE/Rp1vdOvIbrbzFb7UlAoIBAE3ckfthI/ajquvuLWz5vdMfUpF01uFJtC8mPH/7+Gu479Hdq9INdwQp6RJ2110BspesjYAflqQmXChi3ACLkyU8ytqqZZSm70bZm012+5ey/M+iDVCITgp5nM0yzIFDv+wzOBpJU8HerbTpHD0HU0wYzU2ypDzL0Q6RLEsGnjTuwZPQlk3kPYhmnfkH1SQOtG9ygzgGEquYv3jKrxiASxOB0tq15s8BOUDF0s/sP7R4B/a3WoHWCvqIVqVck64AMfHnpMuRDWo6a6cuU+NbVxFq+1v2mRvNuJSChY6EGO1dlCYRfq1L4MonVN+SUMIRd1pQT9GnW9068hutvMVvtSUCgYEAzIonUH220N/wfheqflplj6FA/BbwBgOKECC9ucBGYsaPJDEssvAbG1jB63DQZfv0NPuihD8Op/0H4DEV7RplllkdJUpMVHLjQ1sTuRKvQYB4HmxF56ngy3RzcOIHGgJKztnmlVdFqex9b4vezB5gKSeSBeJ9RtSRn6CQI5VJdt8CgYEApK9KOKHu6jg671bZzcBrilSwPmJn82x7Odau0MzZVjfLQCFz4HweNyXO00fQSR/yxXaeXsLvwE5fzW/uuxdQYLbJBxza++Lzba5kyKRqVPW8VReD7IWHdM9WHuzOLvZq6DvxHSf+smkS5POpfCrSBus+otpF+O05gTp4008B5ScCgYBz0c8NPwJkKEpPvCrovVtBB3h6xqpHXX2yQDfulLfGetTXE5lSAa/3vjygixMWjKLt1YdjBynPafIpuuHFjurzRabBVN7/+sZBf7MdWz0uBAcAgyLaWVFXI6uywepvidi+ZJiy++YQoD8vCK6yOokNBMEk3+k8UGXdU9gKriAZVQKBgE06OncWUSCbH+AO/XKEMqobDs8ifJbln1+/MhmOhrjszy6SwXFbIxw/aZ8gxScViVZaSugrSB0JY9nGDNDFnRbNgLYKLRMEGZ2ss2x31bljx16r+VyYPa5kcIFuET5qpjWjrm06zTDDH24oaalltzoxZR0feMLEFDxqvDBzk3LvAoGAfoiZpMm/rBmcq/Lf9frY8/XY/EsPMrQX5dAE2Y1V2vTLAfJ8FLLOjTLt67OKYvMywch0RVSyUdX12CmfQSJnUOLuethuU1rDbBJt/8JOFw4JX7Vm06ZdH15AOhRnwAeevgcDWHX2ArFl3/wTutfZbsd9aGiD5f7w4C7M630qP6Q=-----END RSA PRIVATE KEY-----';
    // var nprk2211 = helper.parsePrivateKeyFromPem(privatekey10);
    // var tt11 = decrypt(tt, nprk2211);
    // print('result33 $tt11');



  }


// ******* temp removed******* //
  // static Future<bool> sendRsaKeysToServer() async {
  //   var ok = false;
  //   if (publicKey != null) {
  //     final prefs = await SharedPreferences.getInstance();
  //     final extractedUserData = json.decode(prefs.getString('apiKey')!);
  //     String token = extractedUserData['token'];
  //     var url = Uri.parse('${myUrl.url}/public-key/add-public-key');
  //     var myHeaders = {'authorization': token};
  //     try {
  //       var response = await http
  //           .post(url, headers: myHeaders, body: {'public-key': Rsa.publicKey});
  //       var data = json.decode(response.body);
  //       if (data['success']) {
  //         ok = true;
  //       } else {
  //         ok = false;
  //       }
  //     } catch (e) {
  //       print(e);
  //     }
  //   }
  //   return ok;
  // }


  // demo
  String encryptWithPublicKey(String text, String publickey) {
    dynamic npk = helper.parsePublicKeyFromPem(publickey);
    var detxt = encrypt(text, npk);

    return detxt;
  }

   void decryptWithPrivateKey(String text, String privateKey) {
    dynamic nprk = helper.parsePrivateKeyFromPem(privateKey);
    var entxt = decrypt(text, nprk);
    print('decrypt $entxt');
  }

  // String decrypt(String encrypted) {
  //   final key =
  //       Key.fromUtf8("1245714587458888"); //hardcode combination of 16 character
  //   final iv =
  //       IV.fromUtf8("e16ce888a20dadb8"); //hardcode combination of 16 character

  //   final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  //   Encrypted enBase64 = Encrypted.from64(encrypted);
  //   final decrypted = encrypter.decrypt(enBase64, iv: iv);
  //   return decrypted;
  // }

  // String encrypt(String value) {
  //   final key = Key.fromUtf8("1245714587458745"); //hardcode
  //   final iv = IV.fromUtf8("e16ce888a20dadb8"); //hardcode

  //   final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  //   final encrypted = encrypter.encrypt(value, iv: iv);

  //   return encrypted.base64;
  // }

  Future<Map<String, dynamic>> generateKeysNew() async {
    crypto.AsymmetricKeyPair keyPair = await getKeyPair();
    dynamic prk = keyPair.privateKey;
    dynamic pbk = keyPair.publicKey;
    
    dynamic prkS = helper.encodePrivateKeyToPemPKCS1(prk);
    dynamic pbkS = helper.encodePublicKeyToPemPKCS1(pbk);

    final rsaKeys = {'private-key': prkS, 'public-key': pbkS};
   
    return rsaKeys;
   
  }
}
