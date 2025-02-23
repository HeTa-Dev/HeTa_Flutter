import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:provider/provider.dart';
import '../entity/message.dart';
import '../provider/user_provider.dart';
import '../provider/web_socket_provider.dart';
import '../page/self_def_container/chat_bubble.dart';

// 这里是实时聊天页面
// 后期可以增加一个联系人页面，导航到这个页面来进行私聊
class RealtimeChatPage extends StatefulWidget {
  final int receiverId;
  final String receiverName;

  RealtimeChatPage({required this.receiverId, required this.receiverName});

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
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      webSocketProvider.clearMessages();
      webSocketProvider.setCurrentReceiverId(userProvider.user?.id ?? 0);
      webSocketProvider.fetchHistoricalMessages(
        senderId: userProvider.user?.id ?? 0,
        receiverId: widget.receiverId,
        isPrivate: true, // 只加载私信消息
      );
      webSocketProvider.clearUnreadCount(); // 清除未读消息计数
    });
  }

  @override
  Widget build(BuildContext context) {
    final webSocketProvider = Provider.of<WebSocketProvider>(context);
    final userProvider = Provider.of<UserProvider>(context,listen: false);
    final messages = webSocketProvider.messages;
    final user = userProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: Text('与 ${widget.receiverName} 的聊天'),
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
                        receiverId: widget.receiverId,
                        isPrivate: true);
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
                    if (message.receiverId == widget.receiverId && message.isPrivate) {
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
        receiverId: widget.receiverId,
        content: text.trim(),
        id: null,
        senderAvatarPath: user.avatarPath ?? WebConfig.DEFAULT_IMAGE_PATH, // 这里可以替换为实际的头像路径
        timestamp: DateTime.now(),
        isPrivate: true
      );

      webSocketProvider.sendMessage(message);
      _messageController.clear();
    }
  }
}