import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heta/entity/user.dart';
import 'package:heta/provider/user_provider.dart';
import 'package:provider/provider.dart';
import '../config/web_config.dart';
import '../entity/contact.dart';
import 'realtime_chat_page.dart';
import 'package:http/http.dart' as http;

//这个界面我还没弄，聊天
class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact>? contactList;

  Future<void> _getContacts(int userId) async {
    final response = await http.get(Uri.parse(
        'http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/contacts/getContactsById/$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        contactList = jsonData.map((item) => Contact.fromJson(item)).toList();
      });
      print(contactList?.length.toString());
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      body: contactList == null
          ? Center(child: CircularProgressIndicator())
          : contactList!.isEmpty
          ? Center(child: Text('No contacts found'))
          : ListView.builder(
        itemCount: contactList!.length,
        itemBuilder: (context, index) {
          final contact = contactList?[index];
          final receiver_id = (contact?.chatter1_id==userProvider.user?.id)?contact?.chatter2_id:contact?.chatter1_id;
          final receiver_name =  (contact?.chatter1_id==userProvider.user?.id)?contact?.chatter2_name:contact?.chatter1_name;
          final receiver_avatarPath = (contact?.chatter1_id==userProvider.user?.id)?contact?.chatter2_avatarPath:contact?.chatter1_avatarPath;

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(receiver_avatarPath ?? WebConfig.DEFAULT_IMAGE_PATH),
            ),
            title: Text(receiver_name!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RealtimeChatPage(
                    receiver_id: receiver_id,
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