import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/page/self_def_container/my_post_view_container.dart';
import 'package:http/http.dart' as http;
import '../../entity/post_view.dart';
import '../entity/user.dart';

class userPostsPage extends StatefulWidget {
  final User? user;

  @override
  _UserPostsPageState createState() => _UserPostsPageState();

  userPostsPage(this.user);
}

class _UserPostsPageState extends State<userPostsPage> {
  List<PostView>? postViewList;

  // 异步获取帖子视图
  Future<void> _getPostView() async {
    final response = await http.get(Uri.parse(
        "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/postView/findPostViewByUserId/${widget.user?.id}"));

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
          title: Text("TA的帖子"),
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