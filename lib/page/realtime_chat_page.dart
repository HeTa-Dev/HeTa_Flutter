import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:provider/provider.dart';
import '../entity/message.dart';
import '../provider/user_provider.dart';
import '../provider/web_socket_provider.dart';
import '../page/self_def_container/chat_bubble.dart';

// 这里是实时聊天页面
// 目前只实现了聊天室功能，尚未实现私聊功能
// 后期可以增加一个联系人页面，导航到这个页面来进行私聊
class RealtimeChatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RealtimeChatPageState();
  }
}

class _RealtimeChatPageState extends State<RealtimeChatPage> {
  final TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final webSocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
      webSocketProvider.fetchHistoricalMessages(); // 请求历史消息
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final webSocketProvider = Provider.of<WebSocketProvider>(context);
    final user = userProvider.user;
    final messages = webSocketProvider.messages;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!webSocketProvider.isLoading &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  webSocketProvider.fetchHistoricalMessages(); // 上拉加载更多历史记录
                }
                return true;
              },
              child: ListView.builder(
                reverse: true,
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
                  return ChatBubble(
                    timestamp: message.timestamp ?? DateTime.now(),
                    message: message.content,
                    isMe: message.senderId == user?.id,
                    senderName: message.senderName,
                    avatarPath: message.senderAvatarPath,
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
          ),
        ],
      ),
    );
  }


  void _sendMessage(String text) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final webSocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
    final user = userProvider.user;

    if (text.trim().isNotEmpty) {
      final message = Message(
        senderId: user!.id ?? 0,
        senderName: user.username,
        receiverId: 4,
        content: text.trim(),
        id: null,
        senderAvatarPath: user.avatarPath ?? WebConfig.DEFAULT_IMAGE_PATH,
        timestamp: DateTime.now(),
      );

      webSocketProvider.sendMessage(message);
      _messageController.clear();
    }
  }
}