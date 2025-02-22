
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/main.dart';
import 'package:heta/page/user_detail_page.dart';
import 'package:heta/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


// 这是侧边栏，可以通过主页面appBar上的按钮打开,也可以直接右滑打开
class DrawerPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // 获取当前用户
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    return Drawer(
      elevation: 20,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              DrawerHeader(
                margin: EdgeInsets.all(0),
                padding: EdgeInsets.all(0),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 20,),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        user?.avatarPath ?? WebConfig.DEFAULT_IMAGE_PATH,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(  // 使用 Expanded 包裹 Column
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            user!.username,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                            // 添加ellipsis，防止有的人名字太长导致overflow
                            // 注意ellipsis必须和maxLines结合使用，下同
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            user.personalSlogan ?? "",
                            style: TextStyle(color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://heta-images.oss-cn-shanghai.aliyuncs.com/1686646960611188.webp"),
                    fit: BoxFit.cover
                  )
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('修改资料'),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailPage()));
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('设置'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.power_settings_new), onPressed: () {},
                  ),
                  Text('退出账号')
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('确认退出'),
                      content: Text('你确定要退出账号吗？'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                          child: Text('取消'),
                        ),
                        TextButton(
                          onPressed: () async{
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('isLoggedIn', false);

                            Navigator.of(context).pop(); // 关闭对话框
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => HetaApp()),
                                  (route) => false,
                            );// 执行重启
                          },
                          child: Text('确认'),
                        ),
                      ],
                    );
                  },
                );
              }
            ),
          )
        ],
      ),
    );
  }
}