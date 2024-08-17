import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 这是自定义的聊天气泡
class ChatBubble extends StatelessWidget {
  final String message;
  final String senderName;
  final bool isMe;
  final DateTime timestamp;

  ChatBubble({
    required this.message,
    required this.senderName,
    required this.isMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    // 格式化时间戳为北京时间
    final DateTime localTime = timestamp.toLocal(); // 转换为本地时间
    final DateFormat timeFormat = DateFormat('HH:mm');
    final String formattedTime = timeFormat.format(localTime);

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            senderName,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
        // 如果是自己发的消息，那么就显示在屏幕右侧，蓝底白字，气泡右下为尖角
        // 如果不是自己发的消息，那么就显示在屏幕左侧，灰底黑字，气泡坐下为尖角
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
        Text(
          formattedTime,
          style: TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}