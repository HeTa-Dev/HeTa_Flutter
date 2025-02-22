import 'comment.dart';

class PostView {
  int? id;
  int userId;
  String userName;
  String title;
  String text;
  String coverImagePath;
  List<String>? imagePathList;
  int? coverHeight;
  int? coverWidth;
  //List<Comment>? comments;

  PostView({
    required this.userId,
    required this.title,
    required this.text,
    required this.coverImagePath,
    required this.userName,
    this.id,
    this.imagePathList,
    this.coverHeight,
    this.coverWidth,
   // this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "userName": userName,
      "title": title,
      "text": text,
      "coverImagePath": coverImagePath,
      "imagePathList": imagePathList,
      "coverHeight": coverHeight,
      "coverWidth": coverWidth,
      // 处理 comments 属性，将每个 Comment 对象转为 JSON
     // "comments": comments?.map((comment) => comment.toJson()).toList(),
    };
  }

  factory PostView.fromJson(Map<String, dynamic> json) {
    return PostView(
      id: json["id"],
      userId: json["userId"],
      userName: json["userName"],
      title: json["title"],
      text: json["text"],
      coverImagePath: json["coverImagePath"],
      imagePathList: json["imagePathList"] != null
          ? List<String>.from(json["imagePathList"])
          : null,
      coverHeight: json["coverHeight"],
      coverWidth: json["coverWidth"],
      // 处理 comments 属性，将 JSON 列表转为 Comment 对象列表
      // comments: json["comments"] != null
      //     ? List<Comment>.from(
      //     json["comments"].map((commentJson) => Comment.fromJson(commentJson)))
      //     : null,
    );
  }
}