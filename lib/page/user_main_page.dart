import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heta/page/realtime_chat_page.dart';
import 'package:heta/page/seller_orders.dart';
import 'package:heta/page/user_posts.dart';
import 'package:provider/provider.dart';

import '../config/web_config.dart';
import '../entity/contact.dart';
import '../entity/user.dart';
import '../provider/user_provider.dart';
import 'package:http/http.dart' as http;

class UserProfile extends StatelessWidget {
  final User? user;

  UserProfile({this.user});

  @override
  Widget build(BuildContext context) {
    User? currentUser;
    final userProvider = Provider.of<UserProvider>(context);
    currentUser = userProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: Text('用户主页'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.5),
            ],
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(
                  user?.avatarPath ?? WebConfig.DEFAULT_IMAGE_PATH),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              user!.username,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 10),
            if (user?.isBanned == true)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '该用户被封禁',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            SizedBox(height: 10),
            if (user?.isBanned == true)
              IconButton(
                  icon: Icon(Icons.undo),
                  onPressed: () {
                    http.put(Uri.parse(
                        "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/user/setUnbanned/${user?.id}"));
                  }),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                user!.username,
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            if (currentUser?.type == "administrator" && user?.isBanned == false)
              IconButton(
                icon: Icon(Icons.warning),
                onPressed: () {
                  http.put(Uri.parse(
                      "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/user/setBanned/${user?.id}"));
                },
              ),
/*            Card(
              elevation: 2,
              color: Colors.white.withOpacity(0.8),
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                side: BorderSide( color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          user.followers.toString(),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        ),
                        Text(
                          '粉丝',
                          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                    VerticalDivider(
                      color: Colors.grey[300],
                      width: 2,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          user.following.toString(),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        ),
                        Text(
                          '关注',
                          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),*/
            Container(
                width: double.infinity,
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        backgroundColor: Colors.white.withOpacity(0.8),
                        side: BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 1,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => userPostsPage(user)),
                        );
                      },
                      child: Text('                           查看帖子                            ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 10),
                    if(currentUser?.type=="seller")
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey[800],
                          backgroundColor: Colors.white.withOpacity(0.8),
                          side: BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 1,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => sellerOrdersPage(user)),
                          );
                        },
                        child: Text('                           查看商品                            ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ,
                    SizedBox(height:10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey[800],
                        backgroundColor: Colors.white.withOpacity(0.8),
                        side: BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 1,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        Contact contact = Contact(
                            chatter1_id: currentUser?.id,
                            chatter2_id: user?.id,
                            chatter1_name:currentUser?.username,
                            chatter2_name: user?.username,
                            chatter1_avatarPath: currentUser?.avatarPath,
                            chatter2_avatarPath: user?.avatarPath);
                        final response1 = await http.post(
                            Uri.parse("http://" +
                                WebConfig.SERVER_HOST_ADDRESS +
                                ":8080/heta/contacts/saveContact"),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode(contact.toJson()));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RealtimeChatPage(receiver_id: user?.id,)),
                        );
                      },
                      child: Text('                           一起聊天                            ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
