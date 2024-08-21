import 'package:intl/intl.dart';

class Message {
  int? id;
  int senderId;
  String senderName;
  String content;
  int receiverId;
  DateTime? timestamp;
  String senderAvatarPath;

  Message({
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
    required this.senderAvatarPath,
    this.id,
    this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // 解析时间戳，根据类型判断是 ISO 8601 字符串还是 Unix 时间戳
    DateTime? timestamp;
    if (json['timestamp'] is String) {
      timestamp = DateTime.parse(json['timestamp']).toUtc();
    } else if (json['timestamp'] is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp']).toUtc();
    }

    return Message(
      senderId: json['senderId'],
      senderName: json['senderName'],
      receiverId: json['receiverId'],
      content: json['content'],
      senderAvatarPath: json['senderAvatarPath'],
      id: json['id'],
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "senderId": senderId,
      "senderName": senderName,
      "content": content,
      "receiverId": receiverId,
      "senderAvatarPath": senderAvatarPath,
      "id": id,
      "timestamp": timestamp?.toUtc().toIso8601String(), // 存储 UTC 时间
    };
  }
}