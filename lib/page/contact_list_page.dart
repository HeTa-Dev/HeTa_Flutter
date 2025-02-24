import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heta/entity/user.dart';
import 'package:heta/provider/user_provider.dart';
import 'package:provider/provider.dart';
import '../config/web_config.dart';
import 'realtime_chat_page.dart';
import 'package:http/http.dart' as http;

//这个界面我还没弄，聊天
class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<User>? contactList;

  Future<void> _getContacts(int userId) async {
    final response = await http.get(Uri.parse(
        'http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/user/getContactById/$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        contactList = jsonData.map((item) => User.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  void _loadContacts() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _getContacts(userProvider.user?.id ?? 1);
  }

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: contactList == null
          ? Center(child: CircularProgressIndicator())
          : contactList!.isEmpty
          ? Center(child: Text('No contacts found'))
          : ListView.builder(
        itemCount: contactList!.length,
        itemBuilder: (context, index) {
          final contact = contactList![index];
          final id = contact.id;
          final name = contact.username;

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(contact.avatarPath ?? WebConfig.DEFAULT_IMAGE_PATH),
            ),
            title: Text(name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RealtimeChatPage(
                    receiverId: id ?? 1,
                    receiverName: name,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}