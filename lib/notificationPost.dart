import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/home_page.dart';
import 'package:my_flutter_app/singlePost_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPost extends StatefulWidget {
  final String postUrl;

  NotificationPost({required this.postUrl});

  @override
  _NotificationPostState createState() => _NotificationPostState();
}

class _NotificationPostState extends State<NotificationPost> {
  List<dynamic> result = [];
  bool isLoading = true;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    print('inside fetch post of notification');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');

    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];

      if (authToken != null) {
        print('Authentication Token: $authToken');
        print('the url is here : ${widget.postUrl}');

        // Use authToken instead of tokenString in the Authorization header
        final url = Uri.parse(widget.postUrl);
        try {
          final response = await http.get(url, headers: {
            'Authorization': 'Token $authToken',
            'Content-Type': 'application/json',
          });

          if (response.statusCode == 200) {
            final Map<String, dynamic> responseData =
                json.decode(response.body);
            final postJson = responseData;

            final PostProps post = PostProps(
              username: postJson['post_owner']['post_username'] ?? '',
              id: postJson['id'] ?? 0,
              likes: 0,
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

            setState(() {
              result.add(post);
              isLoading = false;
            });
          } else {
            throw Exception('Failed to load post: ${response.statusCode}');
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
        title: Text('Post Page'),
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
                    'Post',
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
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

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
