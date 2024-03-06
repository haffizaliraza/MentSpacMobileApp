import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_flutter_app/homefeed_page.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:chewie/chewie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostProps {
  final String username;
  final int id;
  final int likes;
  final String post_audio;
  final String post_video;
  final String post_content;
  final String post_image;
  final dynamic post_owner;
  final String date_created;
  bool is_pinned;
  int pinned_id;
  final List<dynamic> comments;
  final String post_contentType;

  PostProps({
    required this.username,
    required this.id,
    required this.likes,
    required this.post_audio,
    required this.post_video,
    required this.post_content,
    required this.post_image,
    required this.post_owner,
    required this.date_created,
    required this.is_pinned,
    required this.pinned_id,
    required this.comments,
    required this.post_contentType,
  });
}

bool isEditingComment = false;
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppState {
  final bool isEdit;
  final String user;

  AppState({
    required this.isEdit,
    required this.user,
  });
}

class SetEditValueAction {
  final bool isEdit;

  SetEditValueAction(this.isEdit);
}

class AuthActions {
  static ThunkAction<AppState> setEditValue(bool isEdit) {
    return (Store<AppState> store) async {
      store.dispatch(SetEditValueAction(isEdit));
    };
  }
}

class SinglePost extends StatefulWidget {
  final PostProps post;

  SinglePost({required this.post});

  @override
  _SinglePostState createState() => _SinglePostState();
}

final TextEditingController commentController = TextEditingController();

class _SinglePostState extends State<SinglePost> {
  late PostProps postData;
  late String formattedDate;
  late bool open;
  late bool openModal;
  late int commentId;
  late String content;
  late List<dynamic> comments;
  late bool isSuccess;
  late bool isSuccessComment;
  late bool isCreateSuccess;
  late bool isLoading;
  late bool isLoadingComment;

  ChewieController? _chewieController;
  AudioPlayer? _audioPlayer;

  Future<void> createComment() async {
    setState(() {
      isLoadingComment = true; // Set loading indicator to true
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');
    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];
      if (authToken != null) {
        final apiUrl = 'http://mentspac.com:8000/api/comments';

        // Replace 'YOUR_ACCESS_TOKEN' with the actual access token or authentication mechanism you are using
        final headers = {
          'Authorization': 'Token $authToken',
          'Content-Type': 'application/json',
        };

        // Replace with the actual parameters you need to send in the request
        final body = {
          'comment_content': content,
          'comment_post': postData.id.toString(),
        };

        try {
          final response = await http.post(
            Uri.parse(apiUrl),
            headers: headers,
            body: json.encode(body),
          );

          if (response.statusCode == 201) {
            Map<String, dynamic> commentData = json.decode(response.body);

            // Create a new comment object from the response
            dynamic newComment = {
              'id': commentData['id'],
              'comment_owner': commentData['comment_owner'],
              'comment_content': commentData['comment_content'],
              'like': commentData['like'],
              'date_created': commentData['date_created'],
              'comment_post': commentData['comment_post'],
            };

            // Update the local state to include the new comment
            setState(() {
              isSuccessComment = true;
              content = '';
              postData.comments.add(newComment);
            });
            showToast('Comment posted successfully');
            commentController.clear();
          } else {
            // Handle other response statuses or errors
            print(
                'Error creating comment. Status code: ${response.statusCode}');
            showToast('Error creating comment');
          }
        } catch (error) {
          // Handle any exceptions during the API call
          print('Error creating comment: $error');
          showToast('Error creating comment');
        } finally {
          setState(() {
            isLoadingComment = false; // Set loading indicator to false
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    postData = widget.post;
    formattedDate = formatDate(postData.date_created);
    open = false;
    openModal = false;
    commentId = 0;
    content = '';
    comments = postData.comments;
    isSuccess = false;
    isSuccessComment = false;
    isCreateSuccess = false;
    isLoading = false;
    isLoadingComment = false;

    // Initialize video player if there is a video URL
    if (postData.post_video != null && postData.post_video.isNotEmpty) {
      _initializeVideoPlayer();
    }

    // Initialize audio player if there is an audio URL
    if (postData.post_audio != null && postData.post_audio.isNotEmpty) {
      _initializeAudioPlayer();
    }

    commentController.text = content;
  }

  String formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
  }

  void handleToggle() {
    setState(() {
      open = !open;
    });
  }

  void handleModal() {
    setState(() {
      openModal = !openModal;
    });
  }

  // void handleEdit(int id, String content) {
  //   setState(() {
  //     commentId = id;
  //     this.content = content;
  //     AuthActions.setEditValue(true);
  //   });
  // }

  void handleEdit(int id, String content) {
    setState(() {
      commentId = id;
      this.content = content;
      isEditingComment = true;
      AuthActions.setEditValue(true);
    });
  }

  Future<void> handleDelete(int deleteId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');

    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];

      if (authToken != null) {
        final apiUrl = 'http://mentspac.com:8000/api/comments/$deleteId';

        final headers = {
          'Authorization': 'Token $authToken',
        };

        try {
          final response = await http.delete(
            Uri.parse(apiUrl),
            headers: headers,
          );

          if (response.statusCode == 204) {
            // Comment deleted successfully
            // Update the local state to remove the deleted comment
            setState(() {
              postData.comments
                  .removeWhere((comment) => comment['id'] == deleteId);
            });

            // Show a success dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Success'),
                  content: Text('Comment deleted successfully.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            // Handle other response statuses or errors
            print(
                'Error deleting comment. Status code: ${response.statusCode}');

            // Show an error dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text('Failed to delete comment. Please try again.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } catch (error) {
          // Handle any exceptions during the API call
          print('Error deleting comment: $error');

          // Show an error dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Failed to delete comment. Please try again.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  Future<void> handleUpdate(int updateId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');

    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];

      if (authToken != null) {
        final apiUrl = 'http://mentspac.com:8000/api/comments/$updateId';

        final headers = {
          'Authorization': 'Token $authToken',
          'Content-Type': 'application/json',
        };

        final body = {
          'comment_content': content,
        };

        try {
          final response = await http.put(
            Uri.parse(apiUrl),
            headers: headers,
            body: json.encode(body),
          );

          if (response.statusCode == 200) {
            // Comment updated successfully

            // Update the local state to reflect the changes
            setState(() {
              final updatedComment = postData.comments
                  .firstWhere((comment) => comment['id'] == updateId);
              updatedComment['comment_content'] = content;
            });

            // Close the edit mode
            AuthActions.setEditValue(false);
            setState(() {
              isEditingComment = false;
            });

            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeFeeds(),
              ),
            );
          } else {
            // Handle other response statuses or errors
            print(
                'Error updating comment. Status code: ${response.statusCode}');
            showToast('Error updating comment');
          }
        } catch (error) {
          // Handle any exceptions during the API call
          print('Error updating comment: $error');
          showToast('Error updating comment');
        }
      }
    }
  }

  void handleChange(String value) {
    setState(() {
      content = value;
    });
  }

  Future<void> handleSubmit() async {
    // Call the createComment method when the submit button is pressed
    await createComment();
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _initializeVideoPlayer() {
    _chewieController = ChewieController(
      videoPlayerController: VideoPlayerController.network(
        postData.post_video!,
      ),
      autoPlay: false,
      looping: false,
    );
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    // _audioPlayer?.setUrl(postData.post_audio ?? '');
  }

  @override
  void dispose() {
    // Dispose video and audio players
    _chewieController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Widget renderMediaContent() {
    if (postData.post_image != null && postData.post_image.isNotEmpty) {
      return Image.network(
        postData.post_image,
        width: 300,
        height: 200,
        errorBuilder: (context, error, stackTrace) {
          // Handle error (e.g., display a placeholder image)
          return const Placeholder();
        },
      );
    } else if (_chewieController != null) {
      // Display video player
      return Chewie(
        controller: _chewieController!,
      );
    } else if (_audioPlayer != null) {
      // Display audio player
      return IconButton(
        icon: Icon(Icons.play_arrow),
        onPressed: () {
          _audioPlayer?.play(UrlSource(postData.post_audio));
        },
      );
    } else {
      return Container(); // No media content
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (postData.post_owner["user_image"] != null ||
                      postData.post_owner["image_url"] != null)
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                          postData.post_owner["user_image"] ??
                              postData.post_owner["image_url"]),
                    )
                  else
                    CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postData.post_owner["post_username"],
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Posted: $formattedDate",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.push_pin,
                    color: postData.is_pinned ? Colors.red : Colors.grey),
                onPressed: pinUnpinedPost,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            postData.post_content,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8),
          // Render only one type of media content
          renderMediaContent(),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.thumb_up),
                  SizedBox(width: 4),
                  Text(postData.likes.toString()),
                ],
              ),
              InkWell(
                onTap: handleToggle,
                child: Row(
                  children: [
                    Icon(Icons.comment),
                    SizedBox(width: 4),
                    Text(comments.length.toString()),
                  ],
                ),
              ),
            ],
          ),
          if (open)
            Column(
              children: [
                if (commentId == 0)
                  Form(
                    key: GlobalKey<FormState>(),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: commentController,
                            onChanged: handleChange,
                            initialValue: isEditingComment ? content : null,
                            decoration: InputDecoration(
                              hintText: 'Enter your comment',
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: content.isEmpty
                              ? null
                              : (isEditingComment
                                  ? () => handleUpdate(commentId)
                                  : handleSubmit),
                          child: Text(isEditingComment ? 'Update' : 'Create'),
                        ),
                      ],
                    ),
                  ),
                if (comments.isNotEmpty)
                  Column(
                    children: comments
                        .map((comment) => Column(
                              children: [
                                Row(
                                  children: [
                                    if (comment?['comment_owner'] != null &&
                                        comment?['comment_owner']
                                                ?["post_username"] !=
                                            null)
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          comment?['comment_owner']
                                                  ?["user_image"] ??
                                              '',
                                        ),
                                      )
                                    else
                                      CircleAvatar(
                                        radius: 20,
                                        child: Icon(Icons.person),
                                      ),
                                    SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (comment?['comment_owner'] != null)
                                          Text(
                                            comment?['comment_owner']
                                                ['post_username'],
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (commentId == comment["id"])
                                      Expanded(
                                        child: TextFormField(
                                          onChanged: handleChange,
                                          initialValue:
                                              comment['comment_content'],
                                          // value: content,
                                          decoration: InputDecoration(
                                            hintText: 'Enter your comment',
                                          ),
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child: Text(comment['comment_content']),
                                      ),
                                    if (isEditingComment)
                                      ElevatedButton(
                                        onPressed: content.isEmpty ||
                                                commentId != comment['id']
                                            ? null
                                            : (() =>
                                                handleUpdate(comment['id'])),
                                        // : (() => handleUpdate(commentId)),
                                        child: Text('Update'),
                                      ),
                                    Icon(Icons.thumb_up),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () =>
                                          handleDelete(comment['id']),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => handleEdit(comment['id'],
                                          comment['comment_content']),
                                    ),
                                  ],
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                if (comments.isEmpty)
                  Text(
                    'No comments yet.', // You can customize this message
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),

          if (openModal)
            ConfirmModal(
              openModal: openModal,
              handleModal: handleModal,
              postId: commentId,
            ),
        ],
      ),
    );
  }

  Future<void> pinUnpinedPost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');

    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];

      if (authToken != null) {
        final apiUrlPin = 'http://mentspac.com:8000/api/pin';
        final apiUrlUnPin =
            'http://mentspac.com:8000/api/pin/${postData.pinned_id}';

        final headers = {
          'Authorization': 'Token $authToken',
          'Content-Type': 'application/json',
        };

        try {
          if (postData.is_pinned) {
            // If post is already pinned, send a DELETE request to unpin it
            final response = await http.delete(
              Uri.parse(apiUrlUnPin),
              headers: headers,
            );

            if (response.statusCode == 204) {
              // Post unpinned successfully
              // Update the local state to reflect the changes
              setState(() {
                postData.is_pinned = !postData.is_pinned;
              });
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeFeeds(),
                ),
              );
            } else {
              // Handle other response statuses or errors
              print(
                  'Error unpinning post. Status code: ${response.statusCode}');
              showToast('Error unpinning post');
            }
          } else {
            // If post is not pinned, send a POST request to pin it
            final response = await http.post(
              Uri.parse(apiUrlPin),
              headers: headers,
              body: json.encode({
                'post': postData.id,
                'user':
                    1, // Replace with the actual user ID or fetch it dynamically
              }),
            );

            if (response.statusCode == 201) {
              // Post pinned successfully
              // Update the local state to reflect the changes
              setState(() {
                postData.is_pinned = !postData.is_pinned;
              });

              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeFeeds(),
                ),
              );
            } else {
              // Handle other response statuses or errors
              print('Error pinning post. Status code: ${response.statusCode}');
              showToast('Error pinning post');
            }
          }
        } catch (error) {
          // Handle any exceptions during the API call
          print('Error pinning/unpinning post: $error');
          showToast('Error pinning/unpinning post');
        }
      }
    }
  }
}

String convertIsoToDate(String isoDate) {
  final DateTime dateTime = DateTime.parse(isoDate);
  return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
}

class ConfirmModal extends StatelessWidget {
  final bool openModal;
  final Function() handleModal;
  final int postId;

  ConfirmModal({
    required this.openModal,
    required this.handleModal,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // ... Your existing widget tree ...

          // Add a placeholder widget if needed
          Container(), // Replace this with an appropriate widget
        ],
      ),
    );
  }
}
