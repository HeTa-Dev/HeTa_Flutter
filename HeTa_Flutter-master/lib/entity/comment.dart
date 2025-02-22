import 'package:intl/intl.dart';

class Comment {
  int? id;
  int userId;
  int postId;
  String userName;
  String content;
  DateTime createdAt;
  String avatarPath; // 新增 avatarPath 属性

  Comment({
    this.id,
    required this.userId,
    required this.postId,
    required this.userName,
    required this.content,
    required this.createdAt,
    required this.avatarPath, // 新增构造函数参数
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "postId": postId,
      "userName": userName,
      "content": content,
      "createdAt": createdAt.toIso8601String(),
      "avatarPath": avatarPath,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["id"],
      userId: json["userId"],
      postId: json["postId"],
      userName: json["userName"],
      content: json["content"],
      createdAt: DateTime.parse(json["createdAt"]),
      avatarPath: json["avatarPath"], // 新增 fromJson 处理
    );
  }
}