import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/page/login_page.dart';

void main() {
  runApp(HetaApp());
}

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
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showLoginDialog());
  }

  Future<void> _showLoginDialog() async {
    bool isAuthenticated = false;

    while (!isAuthenticated) {
      isAuthenticated = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoginPage();
        },
      ) ?? false;
    }
  }

  _buildBody(index) {
    if (index == 0) {
      return Center(child: Text("主页面内容"));
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
        backgroundColor: Colors.green,
        centerTitle: true,
      );
    } else if (index == 2) {
      return AppBar(
        title: Text("发布页"),
        backgroundColor: Colors.green,
        centerTitle: true,
      );
    } else {
      return AppBar(
        title: Text("页面开发中..."),
        backgroundColor: Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(_selectedIndex),
      body: _buildBody(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "搜索"),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.add),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.lightGreen,
              ),
            ),
            label: "发布",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: "日程"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "设置"),
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