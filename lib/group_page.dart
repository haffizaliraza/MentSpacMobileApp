import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/about_page.dart';
import 'package:my_flutter_app/allGroups_page.dart';
import 'package:my_flutter_app/category_page.dart';
import 'package:my_flutter_app/createGroupPost_page.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/homefeed_page.dart';
import 'package:my_flutter_app/login_page.dart';
import 'package:my_flutter_app/singleGroupPost_page.dart';
import 'package:my_flutter_app/usersList_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupScreen extends StatefulWidget {
  final String groupId;

  GroupScreen({required this.groupId});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  late Map<String, dynamic> groupInfo = {};
  List<dynamic> result = [];
  bool isLoading = true;
  int pageNumber = 1;
  bool hasMore = true;
  String filter = 'most_recent';

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchGroupInfo();
    fetchPosts(true, 'most_recent', pageNumber);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 10 &&
          hasMore) {
        fetchPosts(false, filter, pageNumber + 1);
      }
    });
  }

  Future<void> fetchGroupInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');

    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];

      if (authToken != null) {
        print('Authentication Token: $authToken');
        print('here is the group id: ${widget.groupId}');

        final url =
            Uri.parse('http://localhost:8000/api/groups/${widget.groupId}');
        try {
          final response = await http.get(url, headers: {
            'Authorization': 'Token $authToken',
            'Content-Type': 'application/json',
          });
          final Map<String, dynamic> responseData = json.decode(response.body);

          // Assign fetched group information to the variable
          setState(() {
            groupInfo = responseData;
          });
        } catch (error) {
          print('Error fetching group info: $error');
        }
      } else {
        print('Authentication Token is null');
      }
    } else {
      print('Token string is null');
    }
  }

  Future<void> fetchPosts(
      bool updateObject, String fetchFilter, int pageCount) async {
    print('Fetching posts...');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');

    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];

      if (authToken != null) {
        print('Authentication Token: $authToken');
        print('here is the group id: ${widget.groupId}');

        // Use authToken instead of tokenString in the Authorization header
        final url = Uri.parse(
            'http://localhost:8000/api/groups/${widget.groupId}/posts?page_size=1');
        try {
          final response = await http.get(url, headers: {
            'Authorization': 'Token $authToken',
            'Content-Type': 'application/json',
          });
          final Map<String, dynamic> responseData = json.decode(response.body);
          print('here is responseData $responseData');

          final List<dynamic> results = responseData['results'];
          final List<PostGroupProps> postPropsList = [];

          for (var postJson in results) {
            PostGroupProps postProps = PostGroupProps(
              // Map fields from postJson to PostGroupProps fields
              id: postJson['id'] ?? 0,
              // Map other fields accordingly
              // Example:
              username: postJson['post_owner']['post_username'] ?? '',
              likes: 0, // You might need to extract this from the response
              post_audio: postJson['post_audio'] ?? '',
              post_video: postJson['post_video'] ?? '',
              post_content: postJson['post_content'] ?? '',
              post_image: postJson['post_image'] ?? '',
              post_owner: postJson['post_owner'] ?? {},
              date_created: postJson['date_created'] ?? '',
              is_pinned: postJson['is_pinned'] ?? false,
              pinned_id: postJson['pinned_id'] ?? 0,
              comments: postJson['comments'] ?? [],
              post_contentType: postJson['date_created'] ?? '',
            );
            postPropsList.add(postProps);
          }

          setState(() {
            if (updateObject) {
              result = postPropsList;
            } else {
              final Iterable<PostGroupProps> uniqueNewPosts =
                  postPropsList.where(
                (newPost) =>
                    !result.any((prevPost) => prevPost.id == newPost.id),
              );

              result.addAll(uniqueNewPosts);
              print('hello from uniqueNewPosts data $uniqueNewPosts');
            }
            isLoading = false;
            pageNumber++;
          });
        } catch (error) {
          print('hello from catch error $error');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Authentication Token is null');
      }
    } else {
      print('Token string is null');
    }
  }

  void uploadFiles(Map<String, dynamic> formData) async {
    try {
      final response = await http.post(Uri.parse('/posts'), body: formData);
      setState(() {
        final List<dynamic> pinnedPosts =
            result.where((el) => el['is_pinned']).toList();
        final List<dynamic> unPinnedPosts =
            result.where((el) => !el['is_pinned']).toList();
        result = [...pinnedPosts, response.body, ...unPinnedPosts];
      });
    } catch (error) {
      print(error);
    }
  }

  void signUserOut(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');

    // Print statements for debugging
    print('Token removed from local storage');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );

    // Print statement for debugging
    print('Navigation to login screen executed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal[100],
                ),
                child: Text(
                  'MentSpac',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('About'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            ListTile(
              title: Text('Mentspac'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()),
                );
              },
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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GroupFeed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (groupInfo != null)
                Column(
                  children: [
                    Text(
                      groupInfo['group_name'] ?? '',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: 300, // Adjust the width as needed
                      height: 180, // Adjust the height as needed
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            8), // Add border radius for rectangle shape
                        image: DecorationImage(
                          image: NetworkImage(groupInfo['group_icon'] ?? ''),
                          fit: BoxFit.cover, // Cover the entire container
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),

              SizedBox(height: 16),
              // Add your CreateGroupPost widget here
              // ...
              CreateGroupPost(
                uploadFiles: uploadFiles,
                groupId: widget.groupId,
              ),

              // Display posts
              SizedBox(height: 16),
              Column(
                children: result.length > 0
                    ? result.reversed
                        .toList()
                        .map((post) => SingleGroupPost(
                              // key: Key(post['id'].toString()),
                              post: post,
                              groupId: widget.groupId,
                            ))
                        .toList()
                    : [
                        Text(
                          'No posts created',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
              ),
              SizedBox(height: 16),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
