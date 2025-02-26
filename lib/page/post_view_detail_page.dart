import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../entity/post_view.dart';
import '../entity/user.dart';
import '../entity/comment.dart';
import '../provider/user_provider.dart'; // 假设你已经有 Comment 类

// 这里是一个postView的详情页面，通过点击主页面的自定义Container进入
class PostViewDetailPage extends StatefulWidget {
  final PostView postView;

  PostViewDetailPage({required this.postView});

  @override
  _PostViewDetailPageState createState() => _PostViewDetailPageState();
}

class _PostViewDetailPageState extends State<PostViewDetailPage> {
  int _currentIndex = 0; // 默认当前索引为0
  User? user;
  TextEditingController _commentController = TextEditingController();
  List<Comment> comments = []; // 存储获取到的评论

  // 根据postView中的userId获取user信息
  // 在主页的时候只知道userId和userName，这里要用到头像什么的
  _getUser(int userId) async {
    final response = await http.get(
      Uri.parse(
          "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/user/findUserById/$userId"),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData =
          jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        user = User.fromJson(jsonData);
      });
    } else {
      // 处理请求错误
      print("Failed to load user");
    }
  }

  // 获取评论数据
  _getComments() async {
    final response = await http.get(
      Uri.parse(
          "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/comment/findCommentsByPostId/${widget.postView.id}"),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        comments = jsonList.map((json) => Comment.fromJson(json)).toList();
      });
    } else {
      // 处理请求错误
      print("Failed to load comments");
    }
  }

  // 发布评论的方法
  Future<void> _publishComment() async {
    setState(() {
// 显示加载图标
    });

    String commentContent = _commentController.text.trim();
    if (commentContent.isNotEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      Comment newComment = Comment(
        userId: user?.id ?? 0,
        userName: user?.username ?? "",
        userType: user!.type,
        content: commentContent,
        createdAt: DateTime.now(),
        postId: widget.postView.id ?? 0,
        avatarPath: user.avatarPath ?? WebConfig.DEFAULT_IMAGE_PATH,
      );

      try {
        final response = await http.post(
          Uri.parse(
              "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/comment/addNewComment"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(newComment.toJson()),
        );

        setState(() {
// 上传完成，隐藏加载图标
        });

        if (response.statusCode == 200) {
          // 重新获取评论数据
          _getComments();
          _commentController.clear();

          // 显示对话框
          showDialog(
            context: context,
            builder: (context) {
              Future.delayed(Duration(seconds: 1), () {
                // 延迟1秒后关闭对话框
                Navigator.of(context).pop();
              });
              return AlertDialog(
                content: Text("评论发布成功！"),
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (context) {
              Future.delayed(Duration(seconds: 1), () {
                // 延迟1秒后关闭对话框
                Navigator.of(context).pop();
              });
              return AlertDialog(
                content: Text('''评论发布失败！
                                 错误码：${response.statusCode}'''),
              );
            },
          );
        }
      } catch (e) {
        setState(() {
// 出现异常，隐藏加载图标
        });
        showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 1), () {
              // 延迟1秒后关闭对话框
              Navigator.of(context).pop();
            });
            return AlertDialog(
              content: Text('网络异常，请检查网络连接'),
            );
          },
        );
      }
    } else {
      setState(() {
// 评论内容为空，隐藏加载图标
      });
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 1), () {
            // 延迟1秒后关闭对话框
            Navigator.of(context).pop();
          });
          return AlertDialog(
            content: Text('评论内容不能为空'),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getUser(widget.postView.userId);
    _getComments(); // 初始化时获取评论数据
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: user == null
            ? CircularProgressIndicator(
                strokeWidth: 2.5,
              ) // 如果 user 为空，显示加载指示器
            : Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        user!.avatarPath ?? WebConfig.DEFAULT_IMAGE_PATH),
                  ),
                  SizedBox(width: 10),
                  Text(
                    user!.username,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 300, // 设置固定高度
                    child: PageView.builder(
                      itemCount: widget.postView.imagePathList?.length ?? 1,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        String imageUrl =
                            widget.postView.imagePathList != null &&
                                    widget.postView.imagePathList!.isNotEmpty
                                ? widget.postView.imagePathList![index]
                                : widget.postView.coverImagePath;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullScreenImagePage(imageUrl: imageUrl),
                              ),
                            );
                          },
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "${_currentIndex + 1}/${widget.postView.imagePathList?.length ?? 1}")
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.postView.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.postView.text,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  // 显示评论列表
                  if (comments.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '评论',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Divider(),
                        for (Comment comment in comments)
                          CommentContainer(comment: comment),
                      ],
                    ),
                ],
              ),
            ),
          ),
          // 输入框和发布按钮
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    keyboardType: TextInputType.multiline,
                    // 设置键盘类型为多行输入
                    textInputAction: TextInputAction.newline,
                    // 设置回车键行为为换行
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: '请输入评论',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _publishComment,
                  child: Text('发布'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 这是用来查看原图以及进行缩放操作的页面，由于比较简单所以不再另外新建一个文件
// 不过以后如果对文件结构进行重构的时候，这样的页面可以适当调整
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  FullScreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("查看原图"),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: AspectRatio(
            aspectRatio: 0.6,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}

// 评论容器组件
class CommentContainer extends StatelessWidget {
  final Comment comment;

  CommentContainer({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                // 这里假设 Comment 类中有 avatarPath 属性
                backgroundImage: NetworkImage(comment.avatarPath),
                radius: 15,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    if (comment.userType == 'administrator')
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '管理员',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    SizedBox(width: 5), // 添加tag和标题之间的间距
                    Text(
                      comment.userName,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ]),
                  Text(
                    // 格式化日期
                    DateFormat('yyyy-MM-dd HH').format(comment.createdAt) +
                        "点", // 这里根据实际的 createdAt 进行格式化
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.only(left: 30 + 10), // 30 是头像半径，10 是间距
            child: Text(
              comment.content,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
