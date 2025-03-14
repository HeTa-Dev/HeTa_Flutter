import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/entity/user.dart';
import 'package:heta/page/administrator_home_page.dart';
import 'package:heta/page/community_page.dart';
import 'package:heta/page/contact_list_page.dart';
import 'package:heta/page/drawer_page.dart';
import 'package:heta/page/login_page.dart';
import 'package:heta/page/my_page.dart';
import 'package:heta/page/new_post_view_page.dart';
import 'package:heta/page/SearchPage.dart';
import 'package:heta/page/user_home_page.dart';
import 'package:heta/provider/user_provider.dart';
import 'package:heta/provider/web_socket_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
 一些开发过程中总结的经验：
  1.不要把异步方法放到任何widget的build方法里面，这样很容易会导致build无限重复调用。
    这里的异步方法包括但不限于各种http请求，用async关键字修饰
  2.如果你在一个方法里面调用了两条或多条异步方法，那么你最好把这个方法也用async关键字修饰，
    并在你调用的异步方法前面加上await关键字，否则它们执行的顺序将和你的预期不符
  3.使用preCacheImage预加载了一张图片之后，再次调用这张图片的时候不要用CachedNetworkImage,
    否则有可能白白预加载了，它会又一次重新访问这张图片并把它加载到内存中去
    使用NetworkImage即可
*/

// 这里是禾她应用程序的主入口
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => WebSocketProvider()),
      ],
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
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userPhoneNum = prefs.getString('userPhoneNum');
    isLoggedIn = prefs.getBool('isLoggedIn') ?? userPhoneNum != null && userPhoneNum!.isNotEmpty;

    if (isLoggedIn) {
      setState(() {});
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showLoginDialog());
    }
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

      isAuthenticated = userPhoneNum != null && userPhoneNum!.isNotEmpty;
    }

    // 保存登录状态和手机号码
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userPhoneNum', userPhoneNum!);
    prefs.setBool('isLoggedIn', true);
    setState(() {});

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HetaMainPage()));
  }

  // 根据登入时的手机号码获取用户信息，便于显示头像、昵称等等
  Future<User> _fetchUser() async {
    int phoneNum = int.parse(userPhoneNum!);
    final response = await http.get(Uri.parse("http://" + WebConfig.SERVER_HOST_ADDRESS + ":8080/heta/user/findUserByPhoneNum/$phoneNum"));
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    currentUser = User.fromJson(jsonData);
    return currentUser!;
  }

  // 获取用户详细资料，同步到UserProvider中
  getUserDetail() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final response = await http.get(Uri.parse("http://" + WebConfig.SERVER_HOST_ADDRESS + ":8080/heta/user/getUserDetailById/${user!.id}"));
    Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    User tempUser = User.fromJson(jsonData);
    Provider.of<UserProvider>(context, listen: false).setUser(tempUser);
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
              final userProvider = Provider.of<UserProvider>(context, listen: false);
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
    } else if (index == 1) {
      return CommunityPage();
    } else if (index == 3) {
      return ContactListPage();
    } else if (index == 2) {
      return CommunityPage();
    }else if(index == 4){
      return MyPage();
    }
    else {
      return Center(
        child: Text("该页面尚未搭建完成"),
      );
    }
  }

  _buildAppBar(index) {
    if (index == 0) {
      return AppBar(
        title: Text("首页"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 点击搜索图标后跳转到搜索页面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        ],
      );
    } else if (index == 1 || index == 2) {
      return AppBar(
        title: Text("社区"),
        centerTitle: true,
      );
    } else if (index == 3) {
      return AppBar(
        title: Text("消息列表"),
        centerTitle: true,
      );
    }
    else if(index == 4){
     return AppBar(
         title: Text("个人"),
        centerTitle: true,
     );
  }  else{
      return AppBar(
        title: Text("页面开发中..."),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Container();
    }

    return Scaffold(
      appBar: _buildAppBar(_selectedIndex),
      body: _buildBody(_selectedIndex),
      drawer: DrawerPage(),
      bottomNavigationBar: Consumer<WebSocketProvider>(
        builder: (context, webSocketProvider, child) {
          return BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: _selectedIndex == 0 ? Icon(Icons.home) : Icon(Icons.home_outlined),
                  label: "首页"),
              BottomNavigationBarItem(
                  icon: _selectedIndex == 1 ? Icon(Icons.switch_account_rounded) : Icon(Icons.switch_account_outlined),
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
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (webSocketProvider.unreadCount > 0)
                      Container(
                        margin: EdgeInsets.only(left: 15), // 设置红点与图标之间的间距
                        padding: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${webSocketProvider.unreadCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    _selectedIndex == 3 ? Icon(Icons.chat) : Icon(Icons.chat_outlined),
                  ],
                ),
                label: "消息",
              ),
              BottomNavigationBarItem(
                  icon: _selectedIndex == 4 ? Icon(Icons.person) : Icon(Icons.person_outlined),
                  label: "我的"),
            ],
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 3) {
                  Provider.of<WebSocketProvider>(context, listen: false).clearUnreadCount(); // 清除未读消息计数
                }
              });
            },
          );
        },
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, 20), // 调整 Y 轴的值来控制下移的距离
        child: Container(
          height: 60,
          width: 60,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return NewPostViewPage();
              }));
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}