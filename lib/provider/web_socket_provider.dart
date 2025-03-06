import 'package:flutter/material.dart';
import 'package:heta/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../entity/message.dart';
import '../config/web_config.dart';

class WebSocketProvider with ChangeNotifier {
  int? _currentReceiverId;
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://${WebConfig.SERVER_HOST_ADDRESS}:8080/chat'),
  );
  final List<Message> _messages = [];
  bool _isLoading = false;
  int _page = 0;
  final int _pageSize = 10;
  int _unreadCount = 0;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  WebSocketProvider() {
    _listenToMessages();
  }

  // 监听 WebSocket 消息
  void _listenToMessages() {
    channel.stream.listen((data) {
      final Map<String, dynamic> json = jsonDecode(data);
      final message = Message.fromJson(json);
      // 检查消息的发送者是否是当前用户的聊天对象
      if (message.senderId == getCurrentReceiverId()) {
        _messages.insert(0, message);
      }
      _unreadCount++;
      notifyListeners();
    }, onError: (error) {
    }, onDone: () {
    });
  }

  // 清空消息列表
  void clearMessages() {
    _messages.clear();
    _page = 0; // 重置分页
    notifyListeners();
  }

  // 根据 receiverId 获取历史消息
  Future<void> fetchHistoricalMessages({required int? senderId, required int? receiverId}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    final response = await http.get(Uri.parse(
        'http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/messages/getMessageById/$senderId/$receiverId/${_page * _pageSize}/$_pageSize'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));_messages.addAll(data.map((json) => Message.fromJson(json)).toList());
      _page++;
    }
    _isLoading = false;
    notifyListeners();
  }

  // 发送消息
  Future<void> sendMessage(Message message) async {
    _messages.insert(0, message);
    _unreadCount--;
    channel.sink.add(jsonEncode(message.toJson()));

    final response1 = await http.post(
      Uri.parse("http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/message/saveMessage"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(message.toJson()),
    );
  }

  // 清空未读消息计数
  void clearUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  // 设置当前的聊天对象 ID
  void setCurrentReceiverId(int? receiverId) {
    _currentReceiverId = receiverId;
    notifyListeners();
  }

  // 获取当前聊天对象的 ID
  int getCurrentReceiverId() {
    return _currentReceiverId ?? 0; // 返回当前的 receiverId
  }
}