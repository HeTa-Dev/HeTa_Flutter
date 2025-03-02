
import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String _developerInfo = '禾她是一款专注于维护委托社群的 APP，对于委托接受和发布过程进行第三方监管。APP 分为两类账号，一类是coser 账号，一类是用户账号。单主可在平台上建立个人账户，完善相关信息之后发布自己所需的委托内容和要求。委托结束后，单主可发布对于委托的推荐帖。平台的目标是完善和规范委托过程，促进委托行业的良性竞争。 平台的理念为女性友好的社群环境，作为“她们”之间的桥梁，“和她们”一起提供一份不掺杂经济纠纷的纯粹圆梦体验。';

  void _showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        title: Text('帮助'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.info),
            title: Text('关于禾她'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '禾她',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(Icons.apps),
                children: <Widget>[
                  Text(_developerInfo),
                ],
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('软件功能介绍'),
            onTap: () {
              _showAlertDialog(context, '提示', '软件功能介绍暂未开放');
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('反馈'),
            onTap: () {
              _showAlertDialog(context, '提示', '反馈功能暂未开放');
            },
          ),
        ],
      ),
    );
  }
}


