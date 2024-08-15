class Message {
  int? id;
  int senderId;
  String senderName;
  String content;
  int receiverId;
  Message({required this.senderId,required this.senderName,
            required this.receiverId,required this.content,this.id});
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json["senderId"],
      senderName: json["senderName"],
      receiverId: json["receiverId"],
      content: json["content"],
      id: json["id"]
    );
  }

  Map<String,dynamic> toJson() {
    return {
      "senderId":senderId,
      "senderName":senderName,
      "content":content,
      "receiverId":receiverId,
      "id":id
    };
  }
}