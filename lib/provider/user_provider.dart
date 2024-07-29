import 'package:flutter/cupertino.dart';

import '../entity/user.dart';

class UserProvider with ChangeNotifier{
  User? _user;
  User? get user => _user;
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}