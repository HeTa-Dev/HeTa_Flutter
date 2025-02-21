import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/page/new_post_view_page.dart';
import 'package:heta/page/self_def_container/post_view_container.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../entity/post_view.dart';
import '../provider/user_provider.dart';
import '../provider/web_socket_provider.dart';


// 这里是用户进入app后的主页面，显示市场上的各种交易
class CommunityPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CommunityPage();
  }
}

class _CommunityPage extends State<CommunityPage> {
  List<PostView>? postViewList;
  // 异步获取订单视图
  Future<void> _getPostView() async {
    final response = await http.get(Uri.parse(
        "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/postView/findAllPostView"));

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
    // 提前加载侧边栏背景图片
    precacheImage(NetworkImage("https://heta-images.oss-cn-shanghai.aliyuncs.com/1686646960611188.webp"), context);
    final userProvider = Provider.of<UserProvider>(context,listen: false);
    final user = userProvider.user;
    precacheImage(NetworkImage(user?.avatarPath??WebConfig.DEFAULT_IMAGE_PATH), context);

    if (postViewList == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
        body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _getPostView,
                child:
                WaterfallFlow.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 控制列的数量
                    mainAxisSpacing: 5, // 主轴方向的间距
                    crossAxisSpacing: 5, // 交叉轴方向的间距
                  ),
                  itemCount: postViewList?.length,
                  itemBuilder: (BuildContext context, int index){
                    return PostViewContainer(postView: postViewList![index]);
                  },
                ),
              ),
            ]
        )
    );
  }

}