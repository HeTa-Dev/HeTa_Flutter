class Contact {
  int? id;
  int? chatter1_id;
  int? chatter2_id;
  String? chatter1_name;
  String? chatter2_name;
  String? chatter1_avatarPath;
  String? chatter2_avatarPath;

  Contact({
    this.id,
    required this.chatter1_id,
    required this.chatter2_id,
    required this.chatter1_name,
    required this.chatter2_name,
    required this.chatter1_avatarPath,
    required this.chatter2_avatarPath,
  });

  // 将对象转换为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatter1_id': chatter1_id,
      'chatter2_id': chatter2_id,
      'chatter1_username': chatter1_name,
      'chatter2_username': chatter2_name,
      'chatter1_avatarPath': chatter1_avatarPath,
      'chatter2_avatarPath': chatter2_avatarPath,
    };
  }

  // 从 JSON 数据中解析并创建对象实例
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      chatter1_id: json['chatter1_id'],
      chatter2_id: json['chatter2_id'],
      chatter1_name: json['chatter1_username'],
      chatter2_name: json['chatter2_username'],
      chatter1_avatarPath: json['chatter1_avatarPath'],
      chatter2_avatarPath: json['chatter2_avatarPath'],
    );
  }
}