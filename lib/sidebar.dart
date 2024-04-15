import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/allGroups_page.dart';
import 'package:my_flutter_app/category_page.dart';
import 'package:my_flutter_app/chat_body.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/homefeed_page.dart';
import 'package:my_flutter_app/modal.dart';
import 'package:my_flutter_app/usersList_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  List<dynamic> chatUsers = []; // sidebar users
  List<dynamic> users = []; // popup users
  List<dynamic> filteredUsers = [];
  List<dynamic> userArray = [];
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
            filteredUsers = jsonDecode(response.body);
            filteredUsers.forEach((item) {
              print(item['roomId']);
              if (item['member'].length >= 2) {
                userArray.add(
                    {'member': item['member'][1], 'roomId': item['roomId']});
              }
            });
            setState(() {
              chatUsers = userArray;
              isLoading = false;
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

  void signUserOut(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');

    // Print statements for debugging
    print('Token removed from local storage');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );

    // Print statement for debugging
    print('Navigation to login screen executed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 100, // Adjust the height as needed
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 183, 228, 245),
                ),
                child: Text(
                  'MentSpac',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('Home Feed'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeFeeds()),
                );
              },
            ),
            ListTile(
              title: Text('Category'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryPage()),
                );
              },
            ),
            ListTile(
              title: Text('Users'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersList()),
                );
              },
            ),
            ListTile(
              title: Text('Groups'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllGroups()),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                signUserOut(context);
              },
            ),
          ],
        ),
      ),
      // backgroundColor: Color.fromARGB(255, 183, 228, 245),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Flexible(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: chatUsers.length,
                    itemBuilder: (context, index) {
                      final user = chatUsers[index]['member'];
                      final roomId = chatUsers[index]['roomId'];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: user['user_image'] != null &&
                                  user['user_image'].isNotEmpty
                              ? NetworkImage(user[
                                  'user_image']) // Use NetworkImage for online image URLs
                              : AssetImage('assets/testimonial-2.jpg')
                                  as ImageProvider<
                                      Object>, // Use AssetImage for local assets
                        ),
                        title: Text(user['post_username'] ??
                            'No Name'), // Display username or fallback to 'No Name'
                        onTap: () {
                          handleUserTap(user, roomId);
                        },
                      );
                    },
                  ),
          ),
          // Modal(
          //     show: isShowAddPeopleModal,
          //     modalCloseHandler: () {
          //       setState(() {
          //         isShowAddPeopleModal = false;
          //       });
          //     },
          //     users: users,
          //     currentUserID: currentUserID,
          //     refreshUI: refreshUI),
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

  void addPeopleClickHandler() async {
    await fetchUsers(); // Fetch users before navigating
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPeopleScreen(
          users: users, // Pass the fetched users list
          currentUserID: currentUserID,
          refreshUI: refreshUI,
        ),
      ),
    );
  }

  void refreshUI() {
    fetchChatUser();
  }
}
