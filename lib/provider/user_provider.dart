import 'package:flutter/cupertino.dart';

import '../entity/user.dart';

// UserProvider 用来存储当前登录的user，它可以在所有页面被调用，只需这样：
// final userProvider = Provider.of<UserProvider>(context);
// final user = userProvider.user;
// 这样你就得到了一个User对象，其中存储了当前登录用户的信息
// 要更新userProvider中的User，可以新创建一个User，然后:
// userProvider.setUser(newUser);
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