import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/page/self_def_container/chat_bubble.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

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
    Uri.parse('ws://${WebConfig.REMOTE_HOST_IPADDRESS}:8080/chat'),
  );
  final List<Message> _messages = [];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context,listen: false);
    final user = userProvider.user;
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final decodedMessage = jsonDecode(snapshot.data);
                    final message = Message.fromJson(decodedMessage);
                    _messages.add(message);
                  }
                  return ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatBubble(
                        message:message.content,
                        isMe: message.senderId == user?.id,
                        senderName: message.senderName,
                      );
                    },
                  );
                },
              ),
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Send a message'),
              onSubmitted: _sendMessage,
            ),
          ],
        )
    );
  }

  void _sendMessage(String text) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (text.isNotEmpty) {
      final message = Message(
        senderId: user!.id??0,
        senderName: user.username,
        receiverId: 2, // 假设消息发送给用户ID为2的用户
        content: _messageController.text,
        id: null,
      );
      channel.sink.add(jsonEncode(message.toJson()));
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }
}