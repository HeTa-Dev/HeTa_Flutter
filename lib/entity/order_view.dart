class OrderView{
  int? id;
  int sellerId;
  String title;
  String text;
  double price;
  String coverImagePath;
  List<String> ?imagePathList;
  List<String> tagList;

  OrderView({
    required this.sellerId,required this.title,required this.text,
    required this.price, required this.coverImagePath,required this.tagList,
    this.id,this.imagePathList});


  // toJSON method to convert OrderView instance to JSON
  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "sellerId": sellerId,
      "title": title,
      "text": text,
      "price": price,
      "coverImagePath": coverImagePath,
      "imagePathList": imagePathList,
      "tagList": tagList,
    };
  }

  // fromJSON method to create OrderView instance from JSON
  factory OrderView.fromJSON(Map<String, dynamic> json) {
    return OrderView(
      id: json["id"],
      sellerId: json["sellerId"],
      title: json["title"],
      text: json["text"],
      price: json["price"],
      coverImagePath: json["coverImagePath"],
      imagePathList: List<String>.from(json["imagePathList"] ?? []),
      tagList: List<String>.from(json["tagList"]),
    );
  }
}