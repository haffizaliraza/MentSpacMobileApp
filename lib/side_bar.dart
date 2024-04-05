import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/chat_body.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  List<dynamic> chatUsers = []; // sidebar users
  List<dynamic> users = []; // popup users
  bool isShowAddPeopleModal = false;
  String? chat_id = '1';

  @override
  void initState() {
    super.initState();
    fetchChatUser();
  }

  Future<void> fetchChatUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final response = await http.get(
            Uri.parse('http://localhost:8000/api/users/1/chats'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            setState(() {
              chatUsers = jsonDecode(response.body);
            });
            print('chat users is here: $chatUsers');
          } else {
            throw Exception('Failed to fetch chat users');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error fetching chat users: $error');
    }
  }

  void handleUserTap(dynamic member, dynamic roomId) {
    print('Member: $member');
    if (member != null) {
      // Add more checks if necessary
      // Access member properties here
      print('Member ID: ${member['id']}');
      print('Member name: ${member['post_username']}');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatBody(
            currentChattingMember: member,
            roomId: roomId,
            // setOnlineUserList: () {}, // Pass the required function
            // chatId: chat_id ?? '', // Pass the chat ID if needed
          ),
        ),
      );
    } else {
      print('Member is null!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: addPeopleClickHandler,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue, // Use your preferred primary color
                padding: EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3, // Add shadow
              ),
              child: Text(
                'Add People',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: chatUsers.length,
              itemBuilder: (context, index) {
                dynamic chatRoom = chatUsers[index];
                Set<String> displayedUserIds = Set();

                List<Widget> memberTiles = [];

                if (chatRoom['member'][1] != null) {
                  for (var member in [chatRoom['member'][1]]) {
                    if (!displayedUserIds.contains(member['id'].toString())) {
                      memberTiles.add(
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25, // Adjust avatar size
                              backgroundImage: member['user_image'] != null &&
                                      member['user_image'].isNotEmpty
                                  ? NetworkImage(member['user_image'])
                                  : AssetImage(
                                          'assets/images/default_user_image.jpg')
                                      as ImageProvider<Object>,
                            ),
                            title: Text(
                              member['post_username'] != null &&
                                      member['post_username'].isNotEmpty
                                  ? member['post_username']
                                  : 'No Name',
                            ),
                            onTap: () {
                              // Handle tap event for this user
                              // print('Tapped on ${member['post_username']}');
                              handleUserTap(member, chatRoom['roomId']);
                            },
                          ),
                        ),
                      );
                      displayedUserIds.add(member['id'].toString());
                    }
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: memberTiles,
                );
              },
            ),
          ),
          Modal(
            show: isShowAddPeopleModal,
            modalCloseHandler: () {
              setState(() {
                isShowAddPeopleModal = false;
              });
            },
            users: users,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Do something similar
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> fetchUsers() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final response = await http.get(
            Uri.parse('http://localhost:8000/api/users?followers=true'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            setState(() {
              users = jsonDecode(response.body);
              isShowAddPeopleModal = true;
            });
          } else {
            throw Exception('Failed to fetch users');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  void addPeopleClickHandler() {
    fetchUsers();
  }
}

class Modal extends StatelessWidget {
  final bool show;
  final VoidCallback modalCloseHandler;
  final List<dynamic> users;

  const Modal({
    Key? key,
    required this.show,
    required this.modalCloseHandler,
    required this.users,
  }) : super(key: key);

  Future<void> addUserToChat(dynamic userId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          final response = await http.post(
            Uri.parse('http://localhost:8000/api/chats'),
            headers: {
              'Authorization': 'Token $authToken',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'members': [userId, 1], // Assuming 1 is the current user's ID
              'type': 'DM',
            }),
          );

          if (response.statusCode == 200) {
            // Handle success response
          } else {
            throw Exception('Failed to add user to chat');
          }
        } else {
          print('Authentication Token is null');
        }
      } else {
        print('Token string is null');
      }
    } catch (error) {
      print('Error adding user to chat: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return show
        ? GestureDetector(
            onTap: modalCloseHandler,
            child: Container(
              // color: Color.fromARGB(137, 105, 206, 219),
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 196, 222, 228),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Add People',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        dynamic user = users[index];
                        return ListTile(
                          title: Text(
                            user['post_username'] ?? 'No Name',
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              addUserToChat(user['id']);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                            ),
                            child: Text(
                              'Add',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: modalCloseHandler,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Change button color
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : SizedBox.shrink();
  }

  void main() {
    runApp(MaterialApp(
      home: SideBar(),
    ));
  }
}
