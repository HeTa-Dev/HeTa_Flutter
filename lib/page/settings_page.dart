import 'dart:math';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _generatedCode = '';
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _verificationCodeController = TextEditingController();

  // 生成随机文字验证码
  String generateVerificationCode() {
    const characters = '0123456789';
    final random = Random();
    return List.generate(6, (index) => characters[random.nextInt(characters.length)]).join();
  }

  // 验证密码强度
  bool _isPasswordStrong(String password) {
    // 密码长度至少为8位
    return password.length >= 8;
  }

  void _showChangePasswordDialog() {
    // 清除之前输入的内容
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _verificationCodeController.clear();

    _generatedCode = generateVerificationCode();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('修改密码'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: '旧密码'),
                ),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: '新密码'),
                ),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: '确认新密码'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _verificationCodeController,
                        decoration: InputDecoration(labelText: '验证码'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _generatedCode = generateVerificationCode();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('验证码已更新: $_generatedCode')),
                        );
                      },
                      child: Text('获取验证码'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                String oldPassword = _oldPasswordController.text;
                String newPassword = _newPasswordController.text;
                String confirmPassword = _confirmPasswordController.text;
                String verificationCode = _verificationCodeController.text;

                if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || verificationCode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('请填写所有字段')),
                  );
                  return;
                }

                if (!_isPasswordStrong(newPassword)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('新密码长度至少为 8 位')),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('新密码和确认密码不一致')),
                  );
                  return;
                }

                if (verificationCode != _generatedCode) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('验证码输入错误')),
                  );
                  return;
                }

                // 这里可以添加实际修改密码的逻辑，比如发送请求到服务器
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('密码修改成功')),
                );
                Navigator.of(context).pop();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: [
          Divider(),
          ListTile(
            leading: Icon(Icons.lock), // 添加锁的图标
            title: Center(child: Text('修改密码')), // 文字居中显示
            onTap: _showChangePasswordDialog,
          ),
          Divider(),
        ],
      ),
    );
  }
}
