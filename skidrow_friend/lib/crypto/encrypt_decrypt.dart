

import 'package:rsa_encrypt/rsa_encrypt.dart';

class Crypto {
late RsaKeyHelper helper;
Crypto() {
  helper = RsaKeyHelper();
}
  String encryptMessageTo({required String publicKeyX, required String message}) {
    dynamic npbk = helper.parsePublicKeyFromPem(publicKeyX);
    var toMessage = encrypt(message, npbk);
    return toMessage;
  }

  String encryptMessageFrom({required String myPublicKey, required String message}) {
    dynamic npbk = helper.parsePublicKeyFromPem(myPublicKey);
    var fromMessage = encrypt(message, npbk);
    return fromMessage;
  }

  String decrypMessage({required String privateKey, required String message}) {
    dynamic nprk = helper.parsePrivateKeyFromPem(privateKey);
    var decryptedmMessage = decrypt(message, nprk); 
    return decryptedmMessage;
  }
}