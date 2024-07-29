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

class UserDetailPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _UserDetailPage();
  }
}

class _UserDetailPage extends State<UserDetailPage>{
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _sloganController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

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

  Future uploadImage(File image) async {
    final uri = Uri.parse('http://192.168.37.205/oss/upload');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      print('Uploaded! URL: $responseData');
      // Handle the URL as needed, for example, display it
    } else {
      print('Failed to upload');
    }
  }
  _getUserDetail() async{
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final response = await http.get(Uri.parse("http://"+WebConfig.SERVER_HOST_ADDRESS+":8080/heta/user/getUserDetailById/${user!.id}"));
    Map<String,dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    User tempUser = User.fromJson(jsonData);
    Provider.of<UserProvider>(context,listen: false).setUser(tempUser);
  }

  @override
  Widget build(BuildContext context) {
    _getUserDetail();
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
                backgroundImage: NetworkImage(user?.avatarPath ??
                    "https://pic.imgdb.cn/item/66a74973d9c307b7e9f02d7f.jpg",
                )
            ),
            SizedBox(height: 10,),
            _image == null ? Text('No image selected.') : Image.file(_image!),
            TextButton(
              child: Text("点击上传头像"),
              onPressed: (){
                  pickImage();
              },
            ),
            Row(
              children: [
                Text("    ID："),
                SizedBox(width: 10,),
                Expanded(
                    child: Text(user!.id.toString())
                )
              ],
            ),
            Row(
              children: [
                Text("昵称："),
                SizedBox(width: 15,),
                Expanded(
                  child:  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: user.username
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
                    child:  TextField(
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
                    child:  TextField(
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
                    child:  TextField(
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
                onPressed: (){
                  if (_image != null) {
                    uploadImage(_image!);
                  }
                },
                child: Text("确认修改")
            )

          ],
        ),
      ),
    )
    );
  }
}