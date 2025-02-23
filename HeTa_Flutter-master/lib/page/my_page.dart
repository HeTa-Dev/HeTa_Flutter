import 'package:flutter/material.dart';
import 'package:heta/page/drawer_page.dart';
import 'package:heta/page/my_page_children/my_post_page.dart';

//这里是我的界面，其中其实只有我发布的帖子的功能，其他没有要求做。
//另外我并没有区分用户，和商人。并没有我的商人发布的商品的功能。
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