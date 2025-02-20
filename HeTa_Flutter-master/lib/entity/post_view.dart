class PostView{
  int? id;
  int userId;
  String userName;
  String title;
  String text;
  String coverImagePath;
  List<String> ?imagePathList;
  int? coverHeight;
  int? coverWidth;

  PostView({
    required this.userId,required this.title,required this.text,
    required this.coverImagePath,
    required this.userName,
    this.id,this.imagePathList,this.coverHeight, this.coverWidth});


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "userName": userName,
      "title": title,
      "text": text,
      "coverImagePath": coverImagePath,
      "imagePathList": imagePathList,
      "coverHeight":coverHeight,
      "coverWidth":coverWidth,
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
        imagePathList: List<String>.from(json["imagePathList"]),
        coverHeight: json["coverHeight"],
        coverWidth: json["coverWidth"]
    );
  }
}