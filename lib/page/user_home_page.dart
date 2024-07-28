import 'package:flutter/cupertino.dart';

class UserHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _UserHomePage();
  }
}

class _UserHomePage extends State<UserHomePage>{
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("这是用户主界面"),);
  }
}