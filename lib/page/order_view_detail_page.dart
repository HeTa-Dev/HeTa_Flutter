import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/page/user_main_page.dart';
import 'package:http/http.dart' as http;

import '../entity/order_view.dart';
import '../entity/user.dart';

// 这里是一个orderView的详情页面，通过点击主页面的自定义Container进入
class OrderViewDetailPage extends StatefulWidget {
  final OrderView orderView;
  OrderViewDetailPage({required this.orderView});

  @override
  _OrderViewDetailPageState createState() => _OrderViewDetailPageState();
}

class _OrderViewDetailPageState extends State<OrderViewDetailPage> {
  int _currentIndex = 0; // 默认当前索引为0
  User? seller;

  // 根据orderView中的sellerId获取seller信息
  // 在主页的时候只知道sellerId和sellerName，这里要用到头像什么的
  _getSeller(int sellerId) async {
    final response = await http.get(
      Uri.parse("http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/user/findUserById/$sellerId"),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        seller = User.fromJson(jsonData);
      });
    } else {
      // 处理请求错误
      print("Failed to load seller");
    }
  }

  @override
  void initState() {
    super.initState();
    _getSeller(widget.orderView.sellerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: seller == null
            ? CircularProgressIndicator(
          strokeWidth: 2.5,
        ) // 如果 user 为空，显示加载指示器
            : Row(
          children: [
            GestureDetector(
                onTap: () {
                  // 点击头像后跳转到新页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserProfile(user: seller)),
                  );
                },
                child: Row(children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        seller!.avatarPath ?? WebConfig.DEFAULT_IMAGE_PATH),
                  ),
                  SizedBox(width: 10),
                  if (seller?.isBanned == true)
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
                ])),
            SizedBox(width: 10),
            Text(
              seller!.username,
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(width: 10),
            //显示管理员标识
            if (seller?.type == 'administrator')
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '管理员',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300, // 设置固定高度
              child: PageView.builder(
                itemCount: widget.orderView.imagePathList?.length ?? 1,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  String imageUrl = widget.orderView.imagePathList != null &&
                      widget.orderView.imagePathList!.isNotEmpty
                      ? widget.orderView.imagePathList![index]
                      : widget.orderView.coverImagePath;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImagePage(imageUrl: imageUrl),
                        ),
                      );
                    },
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${_currentIndex + 1}/${widget.orderView.imagePathList?.length ?? 1}")
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.orderView.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.orderView.text,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\¥${widget.orderView.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    children: widget.orderView.tagList.map((tag) {
                      return Chip(
                        label: Text(tag),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 这是用来查看原图以及进行缩放操作的页面，由于比较简单所以不再另外新建一个文件
// 不过以后如果对文件结构进行重构的时候，这样的页面可以适当调整
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  FullScreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("查看原图"),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: AspectRatio(
            aspectRatio: 0.6,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}