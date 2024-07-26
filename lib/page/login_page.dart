import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  bool? _isPasswdCorrect;
  bool _isPasswdVisible = false;
  bool _isLoading = false; // 新增：加载状态

  TextEditingController _idController = TextEditingController();
  TextEditingController _passwdController = TextEditingController();

  Future<void> _verifyUser(String id, String passwd) async {
    //如果有哪一个输入框没填，为了避免空指针错误就把它们都初始化成"-1"
    if(id==""||passwd==""){
      id = "-1";
      passwd = "-1";
    }else {
      setState(() {
        _isLoading = true; // 开始加载
      });
    }
    String url = "http://localhost:8080/heta/user/verifyUser/${id}/${passwd}";
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> jsonData = jsonDecode(response.body);

    setState(() {
      if (jsonData["result"]) {
        _isPasswdCorrect = true;
        Navigator.of(context).pop(true);
      } else {
        _isPasswdCorrect = false;
      }
      _isLoading = false; // 结束加载
    });
  }

  String? _getErrorText() {
    if (_isPasswdCorrect == false) {
      return "密码或账号不正确，请重新输入！";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(40, 60, 40, 0),
      content: Container(
        width: 300,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "欢迎登录禾她",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                hintText: "请输入ID...",
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _passwdController,
              decoration: InputDecoration(
                hintText: "请输入密码...",
                errorText: _getErrorText(),
                suffixIcon: IconButton(
                  icon: _isPasswdVisible
                      ? Icon(Icons.visibility)
                      : Icon(Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isPasswdVisible = !_isPasswdVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswdVisible,
            ),
            SizedBox(height: 30),
            if (_isLoading) // 根据加载状态显示加载图标
              CircularProgressIndicator(),
            if (!_isLoading) // 登录按钮仅在加载完成时显示
              ElevatedButton(
                child: Text(
                  "登录",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _verifyUser(_idController.text, _passwdController.text);
                },
              ),
          ],
        ),
      ),
    );
  }
}