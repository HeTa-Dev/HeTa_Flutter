import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heta/page/sign_up_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heta/config/web_config.dart';


//这里是登录时显示的那个弹窗
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  bool? _isPasswdCorrect;
  bool _isPasswdVisible = false;
  bool _rememberMyPasswd = false;

  TextEditingController _phoneNumController = TextEditingController();
  TextEditingController _passwdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  //利用SharedPreferences，加载保存的账号和密码方便用户登录
  _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneNumController.text = prefs.getString('phoneNum') ?? '';
      if (prefs.getBool('_rememberMyPasswd') ?? false) {
        _passwdController.text = prefs.getString('password') ?? '';
        _rememberMyPasswd = true;
      }
    });
  }
  //将这次登录的账号密码保存下来
  _saveUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('phoneNum', _phoneNumController.text);
    prefs.setBool('_rememberMyPasswd', _rememberMyPasswd);
    if (_rememberMyPasswd) {
      prefs.setString('password', _passwdController.text);
    } else {
      prefs.remove('password');
    }
  }
  //验证用户输入的的账号密码是否与存储在数据库中的账号密码一致
  _verifyUser(String phoneNum, String passwd) async {
    String url = "http://"+ WebConfig.SERVER_HOST_ADDRESS +":8080/heta/user/verifyUser/$phoneNum/$passwd";
    final response = await http.get(Uri.parse(url));
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    setState(() {
      if (jsonData["result"]) {
        _isPasswdCorrect = true;
        _saveUserInfo();
        Navigator.of(context).pop(phoneNum);
      } else {
        _isPasswdCorrect = false;
      }
    });
  }

  String? _getErrorText() {
    if (_isPasswdCorrect == false) {
      return "密码或手机号不正确，请重新输入！";
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
            controller: _phoneNumController,
            decoration: InputDecoration(hintText: "请输入手机号..."),
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
          SizedBox(height: 10,),
          Row(
            children: [
              Checkbox(
                value: _rememberMyPasswd,
                onChanged: (value) {
                  setState(() {
                    _rememberMyPasswd = value!;
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
              _verifyUser(_phoneNumController.text, _passwdController.text);
            },
          ),
          SizedBox(height: 10,),
          TextButton(
            child: Text(
              "没有账号？点我注册",
              style: TextStyle(
                color: CupertinoColors.activeBlue,
              ),
            ),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder:(context)=> SignUpPage()));
            },
          )
        ],
      ),
    )
    );
  }
}