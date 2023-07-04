import 'package:flutter/foundation.dart';

class ExpansionOpenClose with ChangeNotifier {
  int _selected = -1;

  int get selected => _selected;

  void changeSelecteTile(int index) {
    _selected = index;
    
    notifyListeners();
  }
}