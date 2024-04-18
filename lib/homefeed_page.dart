import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/about_page.dart';
import 'package:my_flutter_app/allGroups_page.dart';
import 'package:my_flutter_app/category_page.dart';
import 'package:my_flutter_app/dummyScreen.dart';
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/login_page.dart';
import 'package:my_flutter_app/side_bar.dart';
import 'package:my_flutter_app/sidebar.dart';
import 'package:my_flutter_app/singlePost_page.dart';
import 'package:my_flutter_app/userProfile_page.dart';
import 'package:my_flutter_app/usersList_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'createPost_page.dart';
import 'package:my_flutter_app/api_config.dart';

class HomeFeeds extends StatefulWidget {
  @override
  _HomeFeedsState createState() => _HomeFeedsState();
}

class _HomeFeedsState extends State<HomeFeeds> {
  String _selectedFilter = 'most_recent';
  List<dynamic> result = [];
  bool isLoading = true;
  int pageNumber = 1;
  bool hasMore = true;
  String filter = 'most_recent';

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchPosts(true, 'most_recent', pageNumber);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 10 &&
          hasMore) {
        fetchPosts(false, filter, pageNumber + 1);
      }
    });
  }

  Future<void> fetchPosts(
      bool updateObject, String fetchFilter, int pageCount) async {
    isLoading = true;
    print('Fetching posts...');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');

    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];

      if (authToken != null) {
        print('Authentication Token: $authToken');

        // Use authToken instead of tokenString in the Authorization header
        final url = Uri.parse(
            '${ApiConfig.baseUrl}/api/user/joined-groups/posts?filter=$fetchFilter&page=$pageCount');
        try {
          final response = await http.get(url, headers: {
            'Authorization': 'Token $authToken',
            'Content-Type': 'application/json',
          });
          final Map<String, dynamic> responseData = json.decode(response.body);

          final Map<String, dynamic>? results =
              responseData['results'] as Map<String, dynamic>?;

          if (results != null) {
            final List<dynamic> posts =
                results['posts'] as List<dynamic>? ?? [];

            List<PostProps> postPropsList = posts.map((postJson) {
              return PostProps(
                username: postJson['post_owner']['post_username'] ?? '',
                id: postJson['id'] ?? 0,
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
            }).toList();

            if (responseData['next'] == null) {
              setState(() {
                hasMore = false;
              });
            }

            setState(() {
              if (updateObject) {
                result = postPropsList;
              } else {
                final Iterable<PostProps> uniqueNewPosts = postPropsList.where(
                  (newPost) =>
                      !result.any((prevPost) => prevPost.id == newPost.id),
                );

                result.addAll(uniqueNewPosts);
                print('hello from uniqueNewPosts data $uniqueNewPosts');
              }
              isLoading = false;
              pageNumber++;
            });
          } else {
            // Handle the case where results is null
            print('Results is null');
          }
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

  // void setFilter(String newFilter) {
  //   setState(() {
  //     filter = newFilter;
  //     pageNumber = 1;
  //     hasMore = true;
  //     result = [];
  //     fetchPosts(true, filter, pageNumber);
  //   });
  // }

  void setFilter(String newFilter) {
    setState(() {
      _selectedFilter = newFilter; // Set selected filter here
      filter = newFilter;
      pageNumber = 1;
      hasMore = true;
      result = [];
      fetchPosts(true, filter, pageNumber);
    });
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
      MaterialPageRoute(builder: (context) => LandingPage()),
    );

    // Print statement for debugging
    print('Navigation to login screen executed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeFeed Page'),
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
              title: Text('Chat'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SideBar()),
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
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()),
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
                    'HomeFeed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = 'trending';
                            });
                            setFilter('trending');
                          },
                          child: Text(
                            'Trending',
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedFilter == 'trending'
                                  ? Colors.white
                                  : null,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            backgroundColor: _selectedFilter == 'trending'
                                ? Color.fromARGB(255, 110, 196, 228)
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = 'most_recent';
                            });
                            setFilter('most_recent');
                          },
                          child: Text(
                            'Most Recent',
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedFilter == 'most_recent'
                                  ? Colors.white // Text color when selected
                                  : null, // Use default text color if not selected
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            backgroundColor: _selectedFilter == 'most_recent'
                                ? Color.fromARGB(255, 110, 196,
                                    228) // Highlight color when selected
                                : null, // Use default color if not selected
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Add your CreatePost widget here
              // ...
              CreatePost(uploadFiles: uploadFiles),

              // Display posts
              SizedBox(height: 16),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : result.isEmpty
                      ? Text(
                          'No posts created',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Column(
                          children: result
                              .map((post) => SinglePost(
                                    post: post,
                                  ))
                              .toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
