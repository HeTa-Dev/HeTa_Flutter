class OrderView{
  int? id;
  int sellerId;
  String sellerName;
  String title;
  String text;
  double price;
  String coverImagePath;
  List<String> ?imagePathList;
  List<String> tagList;
  int? coverHeight;
  int? coverWidth;

  OrderView({
    required this.sellerId,required this.title,required this.text,
    required this.price, required this.coverImagePath,required this.tagList,
    required this.sellerName,
    this.id,this.imagePathList,this.coverHeight, this.coverWidth});


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sellerId": sellerId,
      "sellerName": sellerName,
      "title": title,
      "text": text,
      "price": price,
      "coverImagePath": coverImagePath,
      "imagePathList": imagePathList,
      "tagList": tagList,
      "coverHeight":coverHeight,
      "coverWidth":coverWidth,
    };
  }

  factory OrderView.fromJson(Map<String, dynamic> json) {
    return OrderView(
      id: json["id"],
      sellerId: json["sellerId"],
      sellerName: json["sellerName"],
      title: json["title"],
      text: json["text"],
      price: json["price"],
      coverImagePath: json["coverImagePath"],
      imagePathList: List<String>.from(json["imagePathList"]),
      tagList: List<String>.from(json["tagList"]),
      coverHeight: json["coverHeight"],
      coverWidth: json["coverWidth"]
    );
  }
}