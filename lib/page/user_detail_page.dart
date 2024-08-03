import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:heta/config/web_config.dart';
import 'package:heta/provider/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../entity/user.dart';

// 这里时用户个人资料详情页兼修改页
// 注意：这里不是用户的个人主页，这里的功能更多是修改
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

  // 在手机相册中选择要上传的头像图片
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File compressedImage = await compressToWebP(File(pickedFile.path));
      setState(() {
        _image = compressedImage;
      });
    } else {
      print('No image selected.');
    }
  }
  Future<File> compressToWebP(File file) async {
    final outputFilePath = file.absolute.path + "_compressed.webp";
    final XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outputFilePath,
      format: CompressFormat.webp,
      quality: 50,
    );

    if (compressedImage != null) {
      return File(compressedImage.path);
    } else {
      throw Exception("Image compression failed.");
    }
  }


  Future<void> uploadAvatar(File? image) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    // 上传新头像
    if (image != null) {
      final uri = Uri.parse(
          "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/oss/upload");
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();
      print("上传了新头像！");
      if (response.statusCode == 200) {
        var newAvatarPath = await response.stream.bytesToString();

        // 删除旧头像
        if (user?.avatarPath != null) {
          await http.delete(
            Uri.parse(
                "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/oss/delete"),
            body: jsonEncode({"path": user?.avatarPath}),
          );
          print("删除了旧头像！");
        }

        // 更新用户的头像路径
        user?.avatarPath = newAvatarPath;
        userProvider.setUser(user!); // 更新全局的 user 对象
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
          },
        );
      }
    }
  }


  Future<void> updateUserInfo() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    // 创建一个临时的User对象，准备发送更新请求
    User tempUser = User(
        username: _usernameController.text,
        passwd: user!.passwd,
        type: user.type,
        phoneNum: user.phoneNum,
        avatarPath: user.avatarPath,
        age: int.parse(_ageController.text),
        address: _addressController.text,
        personalSlogan: _sloganController.text,
        id: user.id);

    // 同时更新userProvider中的user
    userProvider.setUser(tempUser);

    // 发送PUT请求更新用户信息
    final response1 = await http.put(
      Uri.parse(
          "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/user/updateUser"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(tempUser.toJSON()),
    );
    print("更新了用户信息！");

    // 显示操作结果
    if (response1.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop(true);
            Navigator.of(context).pop(true);
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            content: Text("更新信息成功！"),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            content: Text("更新信息失败！错误码：${response1.statusCode}"),
          );
        },
      );
    }
  }

  // 显示加载弹窗
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止点击空白区域关闭对话框
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("正在加载，请稍候..."),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user!;

    // 这里需要在initSate方法里面初始化这些Controller
    // 不可以放到build里，因为每次从相册选图片都会重新setState，你之前辛辛苦苦填的东西就没了
    _usernameController = TextEditingController(text: user.username);
    _ageController = TextEditingController(text: user.age.toString());
    _addressController = TextEditingController(text: user.address ?? "");
    _sloganController = TextEditingController(text: user.personalSlogan ?? "");
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text("个人资料详情页"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  user?.avatarPath ?? WebConfig.DEFAULT_IMAGE_PATH),
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
                  SizedBox(width: 10),
                  Expanded(child: Text(user!.id.toString())),
                ],
              ),
              Row(
                children: [
                  Text("昵称："),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: user.username,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("年龄："),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _ageController,
                      decoration:
                          InputDecoration(hintText: user.age.toString()),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("地址："),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _addressController,
                      decoration: InputDecoration(hintText: user.address),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("签名："),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _sloganController,
                      decoration:
                          InputDecoration(hintText: user.personalSlogan),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                // 注意：这里的用法可以参考main.dart中的开发经验第2条
                onPressed: () async {
                  _showLoadingDialog(context); // 显示加载弹窗
                  await uploadAvatar(_image);
                  await updateUserInfo();
                },
                child: Text("确认修改"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
