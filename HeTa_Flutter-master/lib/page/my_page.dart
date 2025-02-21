import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:heta/page/drawer_page.dart';
import 'package:heta/page/my_page_children/my_post_page.dart';
import 'package:heta/page/sign_up_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heta/config/web_config.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("我的账号"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 跳转到“我的账号”页面
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DrawerPage()),
            );
          },
        ),
        Divider(),
        ListTile(
            leading: Icon(Icons.book),
            title: Text("我的帖子"),
            trailing: Icon(Icons.chevron_right),
          onTap: () {
            // 跳转到“我的账号”页面
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyPostsPage()),
            );
          },


        ),
        Divider(),
        ListTile(
            leading: Icon(Icons.timelapse),
            title: Text("浏览历史"),
            trailing: Icon(Icons.chevron_right)),
        Divider(),
        ListTile(
            leading: Icon(Icons.star),
            title: Text("我的收藏"),
            trailing: Icon(Icons.chevron_right)),
        Divider(),
        ListTile(
            leading: Icon(Icons.message),
            title: Text("帮助与反馈"),
            trailing: Icon(Icons.chevron_right)),
        Divider(),
      ],
    );
  }
}