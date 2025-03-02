import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/entity/user.dart';
import 'package:heta/config/web_config.dart';
import 'package:http/http.dart' as http;

// 这里是禾她注册页
// TODO：需要增加验证条件，在密码为空的时候不能允许用户注册
// TODO：需要增加验证条件，在密码不够强的时候不能允许用户注册
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
  // 这个focusNode用来监视第二次输入密码的输入框
  // 每次离开输入框都更新一遍_isPasswordConfirmed
  FocusNode _focusNode = FocusNode();
  // 这个focusNode用来监视手机号的输入框
  // 避免出现用户用一次重复手机号注册之后_isPhoneNumDuplicated恒为true的情况
  FocusNode _focusNode1 = FocusNode();
  // TODO:这里的_typeList要等其他组的同学告知有哪些用户角色并转换成中文，为了方便先这样
  List<String> _typeList = ["customer", "seller", "administrator"];
  bool _isPhoneNumDuplicated = false;
  bool _isPasswordConfirmed = true;
  bool _isSendingCode = false;
  int _countdown = 0;
  String _generatedCode = '';

  List<DropdownMenuEntry<String>> _buildMenuList(List<String> data) {
    return data.map((String value) {
      return DropdownMenuEntry<String>(value: value, label: value);
    }).toList();
  }

  // 验证密码强度
  bool _isPasswordStrong(String password) {
    // 密码长度至少为8位
    return password.length >= 8;
  }

  // 生成随机文字验证码
  String generateVerificationCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(6, (index) => characters[random.nextInt(characters.length)]).join();
  }

  // 发送验证码
  sendVerificationCode() async {
    if (_isSendingCode) return;
    setState(() {
      _isSendingCode = true;
      _countdown = 60;
      _generatedCode = generateVerificationCode();
      // 显示生成的验证码
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            content: Text("验证码是: $_generatedCode"),
          );
        },
      );
    });
    // 启动倒计时
    const oneSec = const Duration(seconds: 1);
    new Future.delayed(Duration.zero, () {
      new Timer.periodic(
        oneSec,
            (Timer timer) {
          setState(() {
            if (_countdown < 1) {
              timer.cancel();
              _isSendingCode = false;
            } else {
              _countdown = _countdown - 1;
            }
          });
        },
      );
    });
  }

  // 用户注册，注册的一系列条件检测也在这个方法里面
  signUpUser() async {
    String password = _passwdController.text;
    // 检查密码是否为空
    if (password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            content: Text("密码不能为空！"),
          );
        },
      );
      return;
    }

    // 检查密码强度
    if (!_isPasswordStrong(password)) {
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            content: Text("密码长度至少为 8 位！"),
          );
        },
      );
      return;
    }

    String verificationCode = _verificationCodeController.text;
    if (verificationCode.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            content: Text("请输入验证码！"),
          );
        },
      );
      return;
    }

    if (verificationCode != _generatedCode) {
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            content: Text("验证码输入错误！"),
          );
        },
      );
      return;
    }

    User user = User(
      username: _usernameController.text,
      passwd: password,
      type: _typeController.text,
      phoneNum: int.parse(_phoneNumberController.text),
      isBanned: false
    );
    final response = await http.post(
      Uri.parse("http://" + WebConfig.SERVER_HOST_ADDRESS + ":8080/heta/user/addNewUser"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    // 检测手机号是否重复
    if (jsonData["duplicated"] == true) {
      setState(() {
        _isPhoneNumDuplicated = true;
      });
    }
    // 手机号重复或者密码前后不一致或者验证码错误都不符合注册条件
    if (!_isPasswordConfirmed || _isPhoneNumDuplicated) {
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            content: Text("不符合注册条件！"),
          );
        },
      );
    } else if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 1), () {
            // 正常注册时候连续退两次Navigator，回到登录页面
            Navigator.of(context).pop(true);
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            content: Text("注册成功"),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 为focusNode添加监视
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
                        errorText: _isPhoneNumDuplicated ? "手机号已注册！" : null,
                      ),
                      controller: _phoneNumberController,
                      focusNode: _focusNode1,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: sendVerificationCode,
                    child: Text(_isSendingCode ? "$_countdown秒后重试" : "获取验证码"),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
                  SizedBox(width: 25), // 添加一个间距
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
                  errorText: _isPasswordConfirmed ? null : "前后密码不一致！",
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