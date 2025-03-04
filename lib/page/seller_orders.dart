import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/page/self_def_container/my_order_view_container.dart';
import 'package:http/http.dart' as http;
import '../../entity/order_view.dart';
import '../entity/user.dart';

class sellerOrdersPage extends StatefulWidget {
  final User? user;

  @override
  _SellerOrdersPageState createState() => _SellerOrdersPageState();

  sellerOrdersPage(this.user);
}

class _SellerOrdersPageState extends State<sellerOrdersPage> {
  List<OrderView>? orderViewList;

  // 异步获取帖子视图
  Future<void> _getOrderView() async {
    final response = await http.get(Uri.parse(
        "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/orderView/findOrderViewBySellerId/${widget.user?.id}"));

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
    if (orderViewList == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
        appBar:AppBar(
          title: Text("TA的商品"),
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