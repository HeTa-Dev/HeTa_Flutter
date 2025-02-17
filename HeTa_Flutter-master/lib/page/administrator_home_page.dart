import 'package:flutter/cupertino.dart';

class AdministratorHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _AdministratorHomePage();
  }
}

class _AdministratorHomePage extends State<AdministratorHomePage>{
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("这是管理员主界面"),);
  }
}