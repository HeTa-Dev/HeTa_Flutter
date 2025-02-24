import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/page/self_def_container/search_order_view_container.dart';
import 'package:http/http.dart' as http;
import '../entity/order_view.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<OrderView>? orderViewList;
  bool isLoading = false; // 新增状态变量，用于控制加载指示器的显示

  // 异步搜索订单
  Future<void> _searchOrderView(String itemName) async {
    setState(() {
      isLoading = true; // 开始请求时显示加载指示器
    });
    try {
      final response = await http.get(Uri.parse(
          "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/orderView/findOrderViewByItemName/$itemName"));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData =
        jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          // 将 JSON 列表解析为 List<OrderView>
          orderViewList =
              jsonData.map((item) => OrderView.fromJson(item)).toList();
          isLoading = false; // 请求完成后隐藏加载指示器
        });
      } else {
        setState(() {
          isLoading = false; // 请求失败时隐藏加载指示器
        });
        throw Exception('Failed to search orders');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // 发生异常时隐藏加载指示器
      });
      print('Error: $e');
    }
  }

  // 显示提醒对话框
  void _showEmptyInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('输入不能为空'),
        );
      },
    );
    // 自动关闭对话框
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                    hintText: '输入目标订单',
                    fillColor: Colors.grey
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                final itemName = _searchController.text;
                if (itemName.isEmpty) {
                  _showEmptyInputDialog();
                } else {
                  _searchOrderView(itemName);
                }
              },
              icon: const Icon(Icons.search),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 搜索结果展示
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (orderViewList == null)
            const SizedBox.shrink() // 初始状态不显示任何内容
          else if (orderViewList!.isEmpty)
              const Expanded(
                child: Center(child: Text('未找到相关订单')),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: orderViewList?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SearchOrderViewContainer(
                          orderView: orderViewList![index]),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}