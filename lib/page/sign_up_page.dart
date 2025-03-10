import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/entity/user.dart';
import 'package:heta/config/web_config.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignUpPage();
  }
}

class _SignUpPage extends State<SignUpPage> {
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwdController = TextEditingController();
  TextEditingController _confirmController = TextEditingController();
  TextEditingController _typeController = TextEditingController();
  TextEditingController _verificationCodeController = TextEditingController();

  FocusNode _focusNode = FocusNode();
  FocusNode _focusNode1 = FocusNode();

  List<String> _typeList = ["customer", "seller", "administrator"];
  bool _isPhoneNumDuplicated = false;
  bool _isPasswordConfirmed = true;
  Uint8List? captchaImageData;
  String? captchaString;

  List<DropdownMenuEntry<String>> _buildMenuList(List<String> data) {
    return data.map((String value) {
      return DropdownMenuEntry<String>(value: value, label: value);
    }).toList();
  }

  bool _isPasswordStrong(String password) {
    return password.length >= 8;
  }

  // 显示提示对话框
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop(true);
        });
        return AlertDialog(
          content: Text(message),
        );
      },
    );
  }


  signUpUser() async {
    String password = _passwdController.text;
    if (password.isEmpty) {
      _showDialog("密码不能为空！");
      return;
    }

    if (!_isPasswordStrong(password)) {
      _showDialog("密码长度至少为 8 位！");
      return;
    }

    String verificationCode = _verificationCodeController.text;
    if (verificationCode.isEmpty) {
      _showDialog("请输入验证码！");
      return;
    }

    int? phoneNum;
    try {
      phoneNum = int.parse(_phoneNumberController.text);
    } catch (e) {
      _showDialog("请输入有效的手机号！");
      return;
    }

    User user = User(
      username: _usernameController.text,
      passwd: password,
      type: _typeController.text,
      phoneNum: phoneNum,
      isBanned: false,
    );

    final uri = Uri.parse(
        "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/user/addNewUser/"
    +verificationCode);

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (captchaString!=verificationCode) {
        _showDialog("验证码输入错误！");
        getCaptchaImage();
        return;
      }
    } else {
      _showDialog("验证码验证失败，请重试！${response.statusCode.toString()}");
      return;
    }

    if (jsonData["duplicated"] == true) {
      setState(() {
        _isPhoneNumDuplicated = true;
      });
    }

    if (!_isPasswordConfirmed || _isPhoneNumDuplicated) {
      _showDialog("不符合注册条件！");
    } else if (response.statusCode == 200) {
      _showDialog("注册成功");
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop(true);
      });
    }
  }

  Future<void> getCaptchaImage() async {
    final response = await http.get(
      Uri.parse(
        "http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/user/captcha",
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      captchaString = data["captchaAnswer"];
      // 将 Base64 编码的字符串解码为 Uint8List
      final base64Image = data['captchaImage'] as String;
      setState(() {
        captchaImageData = base64.decode(base64Image);
      });
    } else {
      _showDialog("获取验证码失败，请重试！");
    }
  }

  @override
  void initState() {
    super.initState();
    getCaptchaImage();
  }

  @override
  Widget build(BuildContext context) {
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _isPasswordConfirmed = _passwdController.text == _confirmController.text;
        });
      }
    });
    _focusNode1.addListener(() {
      if (_focusNode1.hasFocus) {
        setState(() {
          _isPhoneNumDuplicated = false;
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("注册页"),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 100, 20, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "欢迎加入禾她！",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "请输入手机号...",
                        errorText: _isPhoneNumDuplicated? "手机号已注册！" : null,
                      ),
                      controller: _phoneNumberController,
                      focusNode: _focusNode1,
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  captchaImageData!= null
                      ? Image.memory(captchaImageData!)
                      : SizedBox(),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: getCaptchaImage,
                    child: Text("看不清，换一张"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: "请输入验证码...",
                ),
                controller: _verificationCodeController,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "请输入昵称...",
                      ),
                      controller: _usernameController,
                      maxLength: 10,
                    ),
                  ),
                  SizedBox(width: 25),
                  Expanded(
                    child: DropdownMenu(
                      dropdownMenuEntries: _buildMenuList(_typeList),
                      controller: _typeController,
                      label: Text("注册类型", style: TextStyle(fontSize: 13)),
                      width: 170,
                      textStyle: TextStyle(fontSize: 15),
                      initialSelection: _typeList[0],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: "请输入密码...",
                ),
                controller: _passwdController,
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  hintText: "请再次输入密码...",
                  errorText: _isPasswordConfirmed? null : "前后密码不一致！",
                ),
                controller: _confirmController,
                obscureText: true,
                focusNode: _focusNode,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  signUpUser();
                },
                child: Text("提交", style: TextStyle(fontSize: 22)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}