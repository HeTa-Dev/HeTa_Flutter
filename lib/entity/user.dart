class User{
  String username;
  String passwd;
  String type;
  int phoneNum;
  String ?avatarPath;
  int ?age;
  String ?address;
  String ?personalSlogan;
  int ?id;//id由后端自增生成，不用在前端创建时声明

  User({required this.username,
    required this.passwd, required this.type,required this.phoneNum,
    this.avatarPath,this.age,this.address,this.personalSlogan,this.id});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json["username"],
      id: json["id"],
      passwd: json["passwd"],
      type: json["type"],
      phoneNum: json["phoneNum"],
      avatarPath: json["avatarPath"],
      age: json["age"],
      address: json["address"],
      personalSlogan: json["personalSlogan"]
    );
  }

  Map<String,dynamic> toJSON(){
    return{
      "username":username,
      "id":id,
      "passwd":passwd,
      "type":type,
      "phoneNum":phoneNum,
      "avatarPath":avatarPath,
      "age":age,
      "address":address,
      "personalSlogan":personalSlogan
    };
  }
}