import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:heta/entity/user.dart';
import 'package:heta/provider/user_provider.dart';
import 'package:provider/provider.dart';
import '../config/web_config.dart';
import 'realtime_chat_page.dart';
import 'package:http/http.dart' as  http;


class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  late Future<List<Map<String, dynamic>>> _contactsFuture;


  Future<List<Map<String, dynamic>>> _getContacts(int userId) async {
    final response = await http.get(Uri.parse('http://${WebConfig.SERVER_HOST_ADDRESS}:8080/heta/user/getContactById/$userId'));

    if (response.statusCode == 200) {
      // 解析并返回一个 List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load contacts');
    }
  }
  void _loadContacts() {
    final userProvider = Provider.of<UserProvider>(context,listen: false);
    _contactsFuture = _getContacts(userProvider.user?.id ?? 1);
  }

  @override
  Widget build(BuildContext context) {
    _loadContacts();
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load contacts: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts found'));
          } else {
            final contacts = snapshot.data!;
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final id = contact['id'];
                final name = contact['username'];

                return ListTile(
                  title: Text(name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RealtimeChatPage(
                          receiverId: id,
                          receiverName: name,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}