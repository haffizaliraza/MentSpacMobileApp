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
  int currentUserID = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
    fetchChatUser();
  }

  Future<void> getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('token');

    if (userDataString != null) {
      Map<String, dynamic> userData = json.decode(userDataString);
      int? userId = userData['id'];

      if (userId != null) {
        setState(() {
          currentUserID = userId;
        });
        print('current user id is here $currentUserID');
      }
    }
  }

  Future<void> fetchChatUser() async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? tokenString = prefs.getString('token');

      if (tokenString != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenString);
        final String? authToken = tokenMap['auth_token'];

        if (authToken != null) {
          print('before call $currentUserID');
          final response = await http.get(
            Uri.parse('http://localhost:8000/api/users/$currentUserID/chats'),
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
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
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
      appBar: AppBar(
        title: Text('Chats'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: chatUsers.length,
                    itemBuilder: (context, index) {
                      dynamic chatRoom = chatUsers[index];
                      Set<String> displayedUserIds = Set();

                      List<Widget> memberTiles = [];

                      if (chatRoom['member'][1] != null) {
                        for (var member in [chatRoom['member'][1]]) {
                          if (!displayedUserIds
                              .contains(member['id'].toString())) {
                            memberTiles.add(
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 25, // Adjust avatar size
                                    backgroundImage: member['user_image'] !=
                                                null &&
                                            member['user_image'].isNotEmpty
                                        ? NetworkImage(member['user_image'])
                                        : AssetImage('assets/testimonial-2.jpg')
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
              currentUserID: currentUserID,
              refreshUI: refreshUI),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPeopleClickHandler,
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

  void refreshUI() {
    fetchChatUser();
  }
}

class Modal extends StatelessWidget {
  final bool show;
  final VoidCallback modalCloseHandler;
  final List<dynamic> users;
  final int currentUserID;
  final VoidCallback refreshUI;

  const Modal({
    Key? key,
    required this.show,
    required this.modalCloseHandler,
    required this.users,
    required this.currentUserID,
    required this.refreshUI,
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
              'members': [
                userId,
                currentUserID
              ], // Assuming 1 is the current user's ID
              'type': 'DM',
            }),
          );

          if (response.statusCode == 200) {
            // Call refreshUI to update the UI
            refreshUI();
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
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add People',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        dynamic user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 25, // Adjust avatar size
                            backgroundImage: user['user_image'] != null &&
                                    user['user_image'].isNotEmpty
                                ? NetworkImage(user['user_image'])
                                : AssetImage(
                                    'assets/testimonial-2.jpg',
                                  ) as ImageProvider, // Provide a default image asset
                          ),
                          title: Text(
                            user['post_username'] ?? 'No Name',
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              addUserToChat(user['id']);
                              modalCloseHandler();
                              refreshUI();
                            },
                            icon: Icon(Icons.add),
                            color: Colors.blue,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: modalCloseHandler,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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
