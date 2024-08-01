import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/provider/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../entity/user.dart';

// 这里是用户详细资料修改页
// 用户头像从手机相册中选择，然后以http表单形式发送给后端
// 后端再上传到阿里云OSS服务器上，并把生成的图片URL返回给这里
// 同时如果上传成功，则原有的图片会从OSS服务器上删除以节省空间
class UserDetailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserDetailPage();
  }
}

class _UserDetailPage extends State<UserDetailPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _sloganController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;  // 增加一个加载状态，表示上传信息的加载状态

  // 在手机相册中选择要上传的头像图片
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // 更新用户的所有资料
  Future updateUserInfo(File? image) async {
    setState(() {
      _isLoading = true;  // 开始加载
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    // 有图片被选中才上传新图片，不然不用上传
    if (_image != null) {
      final uri = Uri.parse(
          "http://" + WebConfig.SERVER_HOST_ADDRESS + ":8080/heta/oss/upload");
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', image!.path));

      var response = await request.send();

      // 只有成功上传了新头像之后才可以删除旧的头像
      if (response.statusCode == 200) {
        var newAvatarPath = await response.stream.bytesToString();
        var delete = await http.delete(
            Uri.parse("http://"+WebConfig.SERVER_HOST_ADDRESS+":8080/heta/oss/delete"),
            body: {
              "path":user?.avatarPath
            }
        );
        user?.avatarPath = newAvatarPath;
      } else {
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pop(true);
              });
              return AlertDialog(
                content: Text("上传图片失败！"),
              );
            });
      }
    }
    // 创建一个临时的User，准备向后端发送更新请求
    User tempUser = User(
        username: _usernameController.text,
        passwd: user!.passwd,
        type: user.type,
        phoneNum: user.phoneNum,
        avatarPath: user.avatarPath,
        age: int.parse(_ageController.text),
        address: _addressController.text,
        personalSlogan: _sloganController.text,
        id: user.id
    );
    // 同时更新userProvider中的user
    userProvider.setUser(tempUser);
    // 发送PUT请求
    final response1 = await http.put(
        Uri.parse("http://" + WebConfig.SERVER_HOST_ADDRESS + ":8080/heta/user/updateUser"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(tempUser.toJSON())
    );
    setState(() {
      _isLoading = false;  // 加载结束
    });

    print(response1.statusCode);
    if (response1.statusCode == 200) {
      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 1), () {
              Navigator.of(context).pop(true);
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
              content: Text("更新信息成功！"),
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 1), () {
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
              content: Text("更新信息失败！"),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    _usernameController.text = user!.username;
    _ageController.text = user.age.toString();
    _addressController.text = user.address ?? "";
    _sloganController.text = user.personalSlogan ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text("个人资料详情页"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: _isLoading  // 根据加载状态显示不同的内容
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(user?.avatarPath ??
                      "https://pic.imgdb.cn/item/66a74973d9c307b7e9f02d7f.jpg",
                  )
              ),
              _image == null ? Text("") : Image.file(_image!),
              TextButton(
                child: Text("点击上传头像"),
                onPressed: () {
                  pickImage();
                },
              ),
              Row(
                children: [
                  Text("    ID："),
                  SizedBox(width: 10,),
                  Expanded(
                      child: Text(user.id.toString())
                  )
                ],
              ),
              Row(
                children: [
                  Text("昵称："),
                  SizedBox(width: 15,),
                  Expanded(
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: user.username,
                        ),
                      )
                  )
                ],
              ),
              Row(
                children: [
                  Text("年龄："),
                  SizedBox(width: 15,),
                  Expanded(
                      child: TextField(
                        controller: _ageController,
                        decoration: InputDecoration(
                            hintText: user.age.toString()
                        ),
                      )
                  )
                ],
              ),
              Row(
                children: [
                  Text("地址："),
                  SizedBox(width: 15,),
                  Expanded(
                      child: TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                            hintText: user.address
                        ),
                      )
                  )
                ],
              ),
              Row(
                children: [
                  Text("签名："),
                  SizedBox(width: 15,),
                  Expanded(
                      child: TextField(
                        controller: _sloganController,
                        decoration: InputDecoration(
                            hintText: user.personalSlogan
                        ),
                      )
                  )
                ],
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                  onPressed: () {
                    updateUserInfo(_image);
                  },
                  child: Text("确认修改")
              )
            ],
          ),
        ),
      ),
    );
  }
}