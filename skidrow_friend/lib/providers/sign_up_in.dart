
import 'package:flutter/foundation.dart';

class SignMode with ChangeNotifier {
  String? _mode = 'login';
  bool? _loginPasswordEntered = false;
  bool? _loginUsernameEntered = false;

  bool? _showCircularSpinner = false;


  bool? _isAppOpendTap = false;
  bool? get isAppOpendTap {
    return _isAppOpendTap;
  }
  Future<void> setAppOpendTap(bool op) async{
    _isAppOpendTap = op;
    notifyListeners();
  }


  String? get mode {
    return _mode;
  } 

  bool? get loginPasswordEntered {
    return _loginPasswordEntered;
  }

   bool? get loginUsernameEntered {
    return _loginUsernameEntered;
  }

  bool? get showCircularSpinner => _showCircularSpinner;

  void swithchMode(String mode) {
    _mode = mode;
    notifyListeners();
  }

  void setPassword (bool pass) {
    _loginPasswordEntered = pass;
    notifyListeners();
  }

  void setUsername (bool us) {
    _loginUsernameEntered = us;
    notifyListeners();
  }

  void setCircularSpinnerMode(bool cp) {
    _showCircularSpinner = cp;
    notifyListeners();
  }
}