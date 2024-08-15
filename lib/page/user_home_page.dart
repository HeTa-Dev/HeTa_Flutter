import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/page/new_order_view_page.dart';
import 'package:heta/page/self_def_container/order_view_container.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../entity/order_view.dart';
import '../provider/user_provider.dart';


// 这里是用户进入app后的主页面，显示市场上的各种交易
class UserHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserHomePage();
  }
}

class _UserHomePage extends State<UserHomePage> {
  List<OrderView>? orderViewList;
  // 异步获取订单视图
  Future<void> _getOrderView() async {
    final response = await http.get(Uri.parse(
        "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/orderView/findAllOrderView"));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        // 将 JSON 列表解析为 List<OrderView>
        orderViewList =
            jsonData.map((item) => OrderView.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  void initState() {
    super.initState();
    _getOrderView();
  }

  @override
  Widget build(BuildContext context) {
    // 提前加载侧边栏背景图片
    precacheImage(NetworkImage("https://heta-images.oss-cn-shanghai.aliyuncs.com/1686646960611188.webp"), context);
    final userProvider = Provider.of<UserProvider>(context,listen: false);
    final user = userProvider.user;
    precacheImage(NetworkImage(user?.avatarPath??WebConfig.DEFAULT_IMAGE_PATH), context);
    if (orderViewList == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
        body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _getOrderView,
                child:
                WaterfallFlow.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 控制列的数量
                  mainAxisSpacing: 5, // 主轴方向的间距
                  crossAxisSpacing: 5, // 交叉轴方向的间距
                ),
                  itemCount: orderViewList?.length,
                  itemBuilder: (BuildContext context, int index){
                    return OrderViewContainer(orderView: orderViewList![index]);
                  },
                ),
              ),
              
              user?.type =="seller"?Positioned(
                  right: 20,
                  bottom: 20,
                  child: FloatingActionButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewOrderViewPage()),
                      ).then((value) {
                        if (value == true) {
                          _getOrderView(); // 当从 NewOrderViewPage 返回，并且发布成功时刷新订单视图
                        }
                      });
                    },
                    child: Icon(Icons.border_color),
                    shape: CircleBorder(),
                  )
              ):Text("")
            ]
        )
    );
  }

}