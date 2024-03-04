import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_redux/flutter_redux.dart';
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
  final bool is_pinned;
  final int pinned_id;
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');
    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];
      if (authToken != null) {
        final apiUrl = 'http://localhost:8000/api/comments';

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
            // Comment created successfully
            // You can handle the success state as needed
            setState(() {
              isSuccessComment = true;
              content =
                  ''; // Clear the content after successful comment creation
            });
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

  void handleEdit(int id, String content) {
    setState(() {
      commentId = id;
      this.content = content;
      AuthActions.setEditValue(true);
    });
  }

  Future<void> handleDelete(int deleteId) async {
    // You need to implement the delete functionality
    // based on your API or data handling mechanism
    // and handle the state accordingly.
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
                            decoration: InputDecoration(
                              hintText: 'Enter your comment',
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: content.isEmpty ? null : handleSubmit,
                          child: Text('Create'),
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
                                      onPressed: () => handleDelete(comment.id),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => handleEdit(comment.id,
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
    // You need to implement the pin/unpin post functionality
    // based on your API or data handling mechanism
    // and handle the state accordingly.
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
