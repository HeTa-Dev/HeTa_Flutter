import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../entity/message.dart';
import '../config/web_config.dart';

// 这里的 WebSocketProvider 功能和 UserProvider 类似，都是实现全局调用
// 我们不希望用户在进入聊天页面的时候才连接到 socket ，这样的话也没法实现新消息提醒
// 所以我们在应用启动的时候就应该连接到socket，并且始终不断开，直到退出应用
// 后续应该实现应用后台运行的时候，如果收到消息会在用户手机上弹出提示
class WebSocketProvider with ChangeNotifier {

  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://${WebConfig.SERVER_HOST_ADDRESS}:8080/chat'),
  );
  final List<Message> _messages = [];
  bool _isLoading = false;
  int _page = 0;
  final int _pageSize = 10;
  int _unreadCount = 0; // 添加未读消息计数

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading; // 添加一个 getter 用于公开访问 _isLoading
  int get unreadCount => _unreadCount; // 公开未读消息计数

  WebSocketProvider() {
    _listenToMessages();
  }



  void _listenToMessages() {
    channel.stream.listen((data) {
      final Map<String, dynamic> json = jsonDecode(data);
      final message = Message.fromJson(json);
      _messages.insert(0, message);
      _unreadCount++;
      notifyListeners();
    });
  }

  Future<void> fetchHistoricalMessages() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    final response = await http.get(Uri.parse(
        'http://${WebConfig.SERVER_HOST_ADDRESS}:8080/messages/history?offset=${_page * _pageSize}&limit=$_pageSize'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      _messages.addAll(data.map((json) => Message.fromJson(json)).toList());
      _page++;
    } else {
      print('Failed to load historical messages');
    }

    _isLoading = false;
    notifyListeners();
  }

  void sendMessage(Message message) {
    _unreadCount--;// 这里是为了解决自己发消息也会导致未读消息数增加的问题
    channel.sink.add(jsonEncode(message.toJson()));
  }

  void clearUnreadCount() {
    _unreadCount = 0; // 重置未读消息计数
    notifyListeners();
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }
}