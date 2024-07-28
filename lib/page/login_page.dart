import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  bool? isPasswdCorrect;
  bool isPasswdVisible = false;
  bool rememberMe = false;

  TextEditingController _idController = TextEditingController();
  TextEditingController _passwdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idController.text = prefs.getString('username') ?? '';
      if (prefs.getBool('rememberMe') ?? false) {
        _passwdController.text = prefs.getString('password') ?? '';
        rememberMe = true;
      }
    });
  }

  _saveUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', _idController.text);
    prefs.setBool('rememberMe', rememberMe);
    if (rememberMe) {
      prefs.setString('password', _passwdController.text);
    } else {
      prefs.remove('password');
    }
  }

  _verifyUser(String id, String passwd) async {
    String url = "http://8.130.12.168:8080/heta/user/verifyUser/$id/$passwd";
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    setState(() {
      if (jsonData["result"]) {
        isPasswdCorrect = true;
        _saveUserInfo();
        Navigator.of(context).pop(id);
      } else {
        isPasswdCorrect = false;
      }
    });
  }

  String? _getErrorText() {
    if (isPasswdCorrect == false) {
      return "密码或账号不正确，请重新输入！";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(20, 60, 20, 20),
      content:SingleChildScrollView(
      child:  Column(
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
            decoration: InputDecoration(hintText: "请输入ID..."),
          ),
          SizedBox(height: 30),
          TextField(
            controller: _passwdController,
            decoration: InputDecoration(
              hintText: "请输入密码...",
              errorText: _getErrorText(),
              suffixIcon: IconButton(
                icon: isPasswdVisible
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    isPasswdVisible = !isPasswdVisible;
                  });
                },
              ),
            ),
            obscureText: !isPasswdVisible,
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              // SizedBox(width: 100,),
              Checkbox(
                value: rememberMe,
                onChanged: (value) {
                  setState(() {
                    rememberMe = value!;
                  });
                },
              ),
              Text("记住密码"),
            ],
          ),
          SizedBox(height: 30),
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
    )
    );
  }
}