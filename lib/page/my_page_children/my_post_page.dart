import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/page/self_def_container/my_post_view_container.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import '../../entity/post_view.dart';

//这整个文件夹页面，都是my_page跳转后的子页面，之后还可能要写浏览历史等等

// 我的帖子页面
class MyPostsPage extends StatefulWidget {
  @override
  _MyPostsPageState createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  List<PostView>? postViewList;

  // 异步获取帖子视图
  Future<void> _getPostView() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user!;
    final response = await http.get(Uri.parse(
        "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/postView/findPostViewByUserId/${user.id}"));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
      jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        // 将 JSON 列表解析为 List<PostView>
        postViewList =
            jsonData.map((item) => PostView.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  void initState() {
    super.initState();
    _getPostView();
  }

  @override
  Widget build(BuildContext context) {
    if (postViewList == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar:AppBar(
        title: Text("我的帖子"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
        RefreshIndicator(
        onRefresh: _getPostView,
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: postViewList?.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: MyPostViewContainer(postView: postViewList![index]),
            );
          },
        ),
      ),
        ])
    );
  }
}