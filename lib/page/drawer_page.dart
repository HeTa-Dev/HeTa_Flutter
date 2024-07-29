import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/page/user_detail_page.dart';
import 'package:heta/provider/user_provider.dart';
import 'package:provider/provider.dart';

class DrawerPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    return Drawer(
        elevation:20,
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
                          user?.avatarPath ??
                              "https://pic.imgdb.cn/item/66a74973d9c307b7e9f02d7f.jpg",
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            user!.username,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          Text(
                            '',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('个人资料'),
                        onTap: (){
                          Navigator.push(context,MaterialPageRoute(builder:(context)=> UserDetailPage()));},
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
                        icon: Icon(Icons.power_settings_new), onPressed: () {  },
                      ),
                      Text('退出')
                    ],
                  ),
                  onTap: () => Navigator.pop(context),
                )
            )
          ],
        )
    );
  }
}