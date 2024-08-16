import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/page/self_def_container/chat_bubble.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../entity/message.dart';
import '../provider/user_provider.dart';

class RealtimeChatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RealtimeChatPageState();
  }
}

class _RealtimeChatPageState extends State<RealtimeChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://${WebConfig.SERVER_HOST_ADDRESS}:8080/chat'),
  );
  final List<Message> _messages = [];
  bool _isLoading = false;
  int _page = 0;
  final int _pageSize = 10;

  @override
  void initState(){
    super.initState();
    _fetchHistoricalMessages(); // 请求历史消息

    // 监听 WebSocket 收到的消息
    channel.stream.listen((data) {
      final Map<String, dynamic> json = jsonDecode(data);
      final message = Message.fromJson(json);
      setState(() {
        _messages.insert(0,message); // 将收到的新消息添加到列表末尾
      });
    });
  }

  Future<void> _fetchHistoricalMessages() async {
    if (_isLoading) return; // 防止重复加载
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('http://${WebConfig.SERVER_HOST_ADDRESS}:8080/messages/history?offset=${_page * _pageSize}&limit=$_pageSize'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        // 将加载的历史消息添加到列表末尾
        _messages.insertAll(_messages.length, data.map((json) => Message.fromJson(json)).toList());
        _page++;
        _isLoading = false;
      });
    } else {
      // 处理错误
      print('Failed to load historical messages');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!_isLoading &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _fetchHistoricalMessages(); // 上拉加载更多历史记录
                }
                return true;
              },
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _isLoading
                        ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                        : SizedBox.shrink(); // 如果没有在加载，就不显示任何内容
                  }

                  final message = _messages[index];
                  return ChatBubble(
                    timestamp: message.timestamp ?? DateTime.now(),
                    message: message.content,
                    isMe: message.senderId == user?.id,
                    senderName: message.senderName,
                  );
                },
              ),
            ),

          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  maxLines: 100,
                  minLines: 1,
                  controller: _messageController,
                  decoration: InputDecoration(labelText: 'Send a message'),
                ),
              ),
              IconButton(
                onPressed: () {
                  _sendMessage(_messageController.text);
                },
                icon: Icon(Icons.arrow_forward),
              ),
            ],
          )
        ],

      ),
    );
  }

  void _sendMessage(String text) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (text.isNotEmpty) {
      final message = Message(
        senderId: user!.id ?? 0,
        senderName: user.username,
        receiverId: 4, // 假设消息发送给用户ID为4
        content: _messageController.text,
        id: null,
        timestamp: DateTime.now(), // 设置当前时间戳
      );

      channel.sink.add(jsonEncode(message.toJson()));
      // setState(() {
      //   _messages.add(message); // 添加新消息到列表底部
      // });
      _messageController.clear(); // 清空输入框
    }
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }
}