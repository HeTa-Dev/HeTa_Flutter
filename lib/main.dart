import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/entity/user.dart';
import 'package:heta/page/administrator_home_page.dart';
import 'package:heta/page/drawer_page.dart';
import 'package:heta/page/login_page.dart';
import 'package:heta/page/user_home_page.dart';
import 'package:heta/provider/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/*
 一些开发过程中总结的经验：
  1.不要把异步方法放到任何widget的build方法里面，这样很容易会导致build无限重复调用。
    这里的异步方法包括但不限于各种http请求，用async关键字修饰
  2.如果你在一个方法里面调用了两条或多条异步方法，那么你最好把这个方法也用async关键字修饰，
    并在你调用的异步方法前面加上await关键字，否则它们执行的顺序将和你的预期不符
*/

// 这里是禾她应用程序的主入口
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: HetaApp(),
    ),
  );
}

User? currentUser;

class HetaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "禾她",
      home: HetaMainPage(),
    );
  }
}

class HetaMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HetaMainPageState();
  }
}

class _HetaMainPageState extends State<HetaMainPage> {
  // _selectedIndex 用来确定底部导航栏被选中的是哪一个，也就是你现在在哪个页面
  int _selectedIndex = 0;
  String? userPhoneNum;

  @override
  void initState() {
    super.initState();
    // 在进入应用前需要登录，否则无法进入应用
    WidgetsBinding.instance.addPostFrameCallback((_) => _showLoginDialog());
  }
  // 不登录就没法关闭这个弹窗，无法操作应用内的组件
  Future<void> _showLoginDialog() async {
    bool isAuthenticated = false;

    while (!isAuthenticated) {
      userPhoneNum = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoginPage();
        },
      );

      isAuthenticated = userPhoneNum != null && userPhoneNum!.isNotEmpty; // 验证是否已认证
    }

    setState(() {});
  }

  // 根据登入时的手机号码获取用户信息，便于显示头像、昵称等等
  Future<User> _fetchUser() async {
    int phoneNum = int.parse(userPhoneNum!);
    final response = await http.get(Uri.parse("http://"+ WebConfig.SERVER_HOST_ADDRESS +":8080/heta/user/findUserByPhoneNum/$phoneNum"));
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    currentUser = User.fromJson(jsonData);
    return currentUser!;
  }

  // 获取用户详细资料，同步到UserProvider中
  getUserDetail() async{
    final userProvider = Provider.of<UserProvider>(context,listen: false);
    final user = userProvider.user;
    final response = await http.get(Uri.parse("http://"+WebConfig.SERVER_HOST_ADDRESS+":8080/heta/user/getUserDetailById/${user!.id}"));
    Map<String,dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    User tempUser = User.fromJson(jsonData);
    Provider.of<UserProvider>(context,listen: false).setUser(tempUser);
  }

  Widget _buildBody(index) {
    if (index == 0) {
      return FutureBuilder<User>(
        future: _fetchUser(),
        builder: (context, snapshot) {
          // 这里添加了一个转圈圈图标，表示正在加载中
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("加载用户信息时出错！"));
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final userProvider = Provider.of<UserProvider>(context,listen: false);
              userProvider.setUser(currentUser!);
              getUserDetail();
            });
            if (currentUser?.type == "seller" || currentUser?.type == "customer") {
              return UserHomePage();
            } else if (currentUser?.type == "administrator") {
              return AdministratorHomePage();
            }
            return Center(child: Text("未知用户类型！"));
          }
        },
      );
    } else {
      return Center(
        child: Text("该页面尚未搭建完成"),
      );
    }
  }

  _buildAppBar(index) {
    if (index == 0) {
      return AppBar(
        title: Text("首页"),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      );
    } else if (index == 2) {
      return AppBar(
        title: Text("发布页"),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      );
    } else {
      return AppBar(
        title: Text("页面开发中..."),
        backgroundColor: Colors.lightBlue,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(_selectedIndex),
      body: _buildBody(_selectedIndex),
      drawer: DrawerPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: _selectedIndex==0?Icon(Icons.home):Icon(Icons.home_outlined),
              label: "首页"),
          BottomNavigationBarItem(
              icon: _selectedIndex == 1?Icon(Icons.switch_account_rounded):Icon(Icons.switch_account_outlined),
              label: "社区"),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.add),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blueAccent,
              ),
            ),
            label: "发布",
          ),
          BottomNavigationBarItem(
              icon: _selectedIndex==3?Icon(Icons.chat):Icon(Icons.chat_outlined),
              label: "消息"),
          BottomNavigationBarItem(
              icon: _selectedIndex==4?Icon(Icons.person):Icon(Icons.person_outlined),
              label: "我的"),
        ],
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}