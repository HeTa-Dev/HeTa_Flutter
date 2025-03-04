import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/entity/contact.dart';
import 'package:provider/provider.dart';
import '../entity/message.dart';
import '../entity/user.dart';
import '../provider/user_provider.dart';
import '../provider/web_socket_provider.dart';
import '../page/self_def_container/chat_bubble.dart';
import 'package:http/http.dart' as http;

// 这里是实时聊天页面
// 后期可以增加一个联系人页面，导航到这个页面来进行私聊
class RealtimeChatPage extends StatefulWidget {
  final int? receiver_id; // 假设 MessageReceiver 是接收者的实体类

  RealtimeChatPage({required this.receiver_id});

  @override
  State<StatefulWidget> createState() {
    return _RealtimeChatPageState();
  }
}

class _RealtimeChatPageState extends State<RealtimeChatPage> {

  User? receiver; // 接收者信息
  bool isLoading = true; // 加载状态

  Future<void> _loadReceiver() async {
    try {
      final response = await http.get(
        Uri.parse(
            "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/user/findUserById/${widget.receiver_id}"),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          receiver = User.fromJson(jsonData);
          isLoading = false; // 数据加载完成
        });
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // 加载失败
      });
      print('Error loading receiver: $e');
    }
  }
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReceiver();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final webSocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      webSocketProvider.clearMessages();
      webSocketProvider.setCurrentReceiverId(receiver?.id);
      webSocketProvider.fetchHistoricalMessages(
        senderId: userProvider.user?.id ?? 0,
        receiverId: receiver?.id,
        //isPrivate: true, // 只加载私信消息
      );
      webSocketProvider.clearUnreadCount(); // 清除未读消息计数
    });
  }

  @override
  Widget build(BuildContext context) {
    final webSocketProvider = Provider.of<WebSocketProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messages = webSocketProvider.messages;
    final user = userProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: Text('与 ${receiver?.username} 的聊天'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!webSocketProvider.isLoading &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    webSocketProvider.fetchHistoricalMessages(
                      senderId: userProvider.user?.id ?? 0,
                      receiverId: receiver?.id,
                      // isPrivate: true,
                    );
                  }
                  return true;
                },
                child: ListView.builder(
                  reverse: true, // 让最早的消息从最上方开始显示
                  itemCount: messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return webSocketProvider.isLoading
                          ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : SizedBox.shrink();
                    }

                    final message = messages[index];
                    if (message.receiverId == receiver?.id ) {
                      return ChatBubble(
                        timestamp: message.timestamp ?? DateTime.now(),
                        message: message.content,
                        isMe: message.senderId == user!.id,
                        senderName: message.senderName,
                        avatarPath: message.senderAvatarPath,
                      );
                    } else {
                      return SizedBox.shrink(); // 如果不是当前接收者的私信，则不显示
                    }
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
                    decoration: InputDecoration(labelText: '发送消息'),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                  icon: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 void _sendMessage(String text) {
    final webSocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (text.trim().isNotEmpty) {
      final message = Message(
        senderId: user!.id ?? 0,
        senderName: user.username,
        receiverId: receiver?.id,
        content: text.trim(),
        id: null,
        senderAvatarPath: user.avatarPath ?? WebConfig.DEFAULT_IMAGE_PATH, // 这里可以替换为实际的头像路径
        timestamp: DateTime.now(),
        // isPrivate: true,
      );

      webSocketProvider.sendMessage(message);
      _messageController.clear();
    }
  }
}