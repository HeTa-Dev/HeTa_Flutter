import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../entity/comment.dart';

class CommentContainer extends StatelessWidget {
  final Comment comment;

  CommentContainer({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像和昵称部分
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左上角的头像，半径变小
              CircleAvatar(
                backgroundImage: NetworkImage(comment.avatarPath),
                radius: 8, // 头像半径从 10 调整为 8
              ),
              SizedBox(width: 10),
              // 昵称和发布时间部分
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 昵称，字体变小且颜色为灰色
                  Text(
                    comment.userName,
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w200, color: Colors.grey),
                  ),
                  // 发布时间，只精确到时
                  Text(
                    DateFormat('HH').format(comment.createdAt),
                    style: TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),
          // 缩进和昵称齐平的评论内容，字体增大
          Padding(
            padding: EdgeInsets.only(left: 8 * 2 + 10), // 8 是头像半径，乘以 2 得到直径，再加上间距
            child: Text(
              comment.content,
              style: TextStyle(fontSize: 18), // 评论字体大小从 30 调整为 18
            ),
          ),
        ],
      ),
    );
  }
}