class User{
  String username;
  int id;
  String passwd;
  String type;
  String ?avatarPath;
  int ?age;
  String ?address;
  String ?personalSlogan;

  User({required this.id, required this.username,
    required this.passwd, required this.type,
    this.avatarPath,this.age,this.address,this.personalSlogan});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json["username"],
      id: json["id"],
      passwd: json["passwd"],
      type: json["type"],
      avatarPath: json["avatarPath"],
      age: json["age"],
      address: json["address"],
      personalSlogan: json["personalSlogan"]
    );
  }
}