import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/page/self_def_container/my_order_view_container.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import '../../entity/order_view.dart';

//这整个文件夹页面，都是my_page跳转后的子页面，之后还可能要写浏览历史等等

// 我的帖子页面
class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<OrderView>? orderViewList;
  bool isSeller = true;

  // 异步获取帖子视图
  Future<void> _getOrderView() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user!;
    isSeller = (user.type=="seller");
    final response = await http.get(Uri.parse(
        "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/orderView/findOrderViewBySellerId/${user.id}"));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
      jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        // 将 JSON 列表解析为 List<OrderView>
        orderViewList =
            jsonData.map((item) => OrderView.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load orders');
    }
  }

  @override
  void initState() {
    super.initState();
    _getOrderView();
  }

  @override
  Widget build(BuildContext context) {
    if(!isSeller){
      return Scaffold(
        body: Center(child: Text("您当前不是商家，无法发布商品")),
      );
    }
    if (orderViewList == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
        appBar:AppBar(
          title: Text("我的商品"),
          centerTitle: true,
        ),
        body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _getOrderView,
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: orderViewList?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: MyOrderViewContainer(orderView: orderViewList![index]),
                    );
                  },
                ),
              ),
            ])
    );
  }
}