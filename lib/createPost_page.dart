import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:my_flutter_app/homefeed_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:my_flutter_app/api_config.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget(this.videoUrl);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.videoUrl)
        ..initialize().then((_) {
          setState(() {});
          _controller.play();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                VideoPlayer(_controller),
                VideoProgressIndicator(_controller, allowScrubbing: true),
              ],
            ),
          )
        : Container(); // Return an empty container if video is not initialized
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class FileType {
  final String path;
  final int lastModified;
  final DateTime lastModifiedDate;
  final String name;
  final int size;
  final String type;
  final String webkitRelativePath;

  FileType({
    required this.path,
    required this.lastModified,
    required this.lastModifiedDate,
    required this.name,
    required this.size,
    required this.type,
    required this.webkitRelativePath,
  });
}

final TextEditingController postController = TextEditingController();
String? imagePreviewUrl;
String? videoPreviewUrl;
FileType? files;

class CreatePost extends StatefulWidget {
  final Function(Map<String, dynamic>) uploadFiles;

  CreatePost({required this.uploadFiles});

  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  String post = "";
  String isImage = "image";
  bool isOpen = false;
  FileType files = FileType(
    path: "",
    lastModified: 0,
    lastModifiedDate: DateTime.now(),
    name: "",
    size: 0,
    type: "",
    webkitRelativePath: "",
  );
  dynamic previewUrl;
  String error = "";
  late String id;

  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();

    id = "some_id";
  }

  Future<void> validateFileType(FileType files) async {
    print('Validating file type hololo: ${files.type}');
    if (files == null || files.path.isEmpty) {
      setState(() {
        error = "Empty";
      });
      return;
    }

    const List<String> validImageTypes = [
      "image/jpeg",
      "image/png",
      "image/gif"
    ];
    const List<String> validVideoTypes = [
      "video/mp4",
      "video/mpeg",
      "video/webm"
    ];
    const List<String> validAudioTypes = [
      "audio/mpeg",
      "audio/ogg",
      "audio/wav"
    ];

    try {
      // Read file bytes
      List<int> fileBytes;

      if (kIsWeb) {
        // For web, use the bytes property directly
        fileBytes = files.path.codeUnits;
      } else {
        fileBytes = await File(files.path).readAsBytes();
      }

      if (validImageTypes.contains(files.type)) {
        setState(() {
          previewUrl = MemoryImage(Uint8List.fromList(fileBytes));
          imagePreviewUrl = files.path;
        });
      } else if (validVideoTypes.contains(files.type)) {
        // Handle video preview
        setState(() {
          previewUrl = files.path; // Store the path directly for videos
          videoPreviewUrl = files.path;
        });
      } else if (validAudioTypes.contains(files.type)) {
        // Handle audio preview
      } else {
        setState(() {
          error = "Invalid file type selected";
        });
      }
    } catch (e) {
      setState(() {
        error = "Error reading file";
      });
    }
  }

  Future<void> validateFileTypeWeb(Uint8List bytes) async {
    print('Validating file type for web: ${files.type}');
    const List<String> validImageTypes = [
      "image/jpeg",
      "image/png",
      "image/gif"
    ];
    const List<String> validVideoTypes = [
      "video/mp4",
      "video/mpeg",
      "video/webm"
    ];
    const List<String> validAudioTypes = [
      "audio/mpeg",
      "audio/ogg",
      "audio/wav"
    ];

    if (validImageTypes.contains(files.type)) {
      setState(() {
        previewUrl = MemoryImage(bytes);
        imagePreviewUrl = null;
        print('Checking the previewUrl image: ${previewUrl}');
      });
    } else if (validVideoTypes.contains(files.type)) {
      // Handle video preview
      setState(() {
        previewUrl = bytes; // Store the bytes directly for videos
        videoPreviewUrl = null;
        print('Checking the previewUrl video');
      });
    } else if (validAudioTypes.contains(files.type)) {
      // Handle audio preview
    } else {
      setState(() {
        error = "Invalid file type selected";
      });
    }
  }

  Future<void> handleDrop() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        files = FileType(
          path: kIsWeb ? "" : result.files.single.path ?? "",
          lastModified: DateTime.now().millisecondsSinceEpoch,
          lastModifiedDate: DateTime.now(),
          name: result.files.single.name,
          size: result.files.single.size,
          type: lookupMimeType(result.files.single.name) ?? "",
          webkitRelativePath: "",
        );
        error = "";
        imagePreviewUrl = null;
        videoPreviewUrl = null;
      });

      print(
          'File type: ${files?.type}'); // Use the safe navigation operator (?)
      print(
          'File path 1: ${files?.path}'); // Use the safe navigation operator (?)

      // print('File path 2: ${result?.files.single.path}');

      Future.delayed(Duration(milliseconds: 50), () async {
        if (kIsWeb) {
          if (result?.files.single.bytes != null) {
            validateFileTypeWeb(result!.files.single.bytes!);
          } else {
            print('Error: Bytes property is null on the web.');
          }
        } else {
          validateFileType(files); // Pass the files object to the method
        }
      });
    }
  }

  void handleChange(String value) {
    setState(() {
      post = value;
    });
  }

  void handleImage() {
    setState(() {
      isOpen = !isOpen;
      isImage = "image";
      if (files.type.startsWith("video/") || files.type.startsWith("audio/")) {
        print('inside handleImage');
        setState(() {
          files = FileType(
            path: "",
            lastModified: 0,
            lastModifiedDate: DateTime.now(),
            name: "",
            size: 0,
            type: "",
            webkitRelativePath: "",
          );
          imagePreviewUrl = null;
        });
      }
    });
  }

  void handleVideo() {
    setState(() {
      isOpen = !isOpen;
      isImage = "video";
      if (files.type.startsWith("image/") || files.type.startsWith("audio/")) {
        setState(() {
          files = FileType(
            path: "",
            lastModified: 0,
            lastModifiedDate: DateTime.now(),
            name: "",
            size: 0,
            type: "",
            webkitRelativePath: "",
          );
          videoPreviewUrl = null;
        });
      }
    });
  }

  void handleAudio() {
    setState(() {
      isOpen = !isOpen;
      isImage = "audio";
      if (files.type.startsWith("image/") || files.type.startsWith("video/")) {
        setState(() {
          files = FileType(
            path: "",
            lastModified: 0,
            lastModifiedDate: DateTime.now(),
            name: "",
            size: 0,
            type: "",
            webkitRelativePath: "",
          );
        });
      }
    });
  }

  Future<void> handleSubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');

    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];

      final formData = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/posts'),
      );

      formData.fields.addAll({
        "post_content": post,
        "like": false.toString(),
      });

      // Add media file if selected
      if (files?.path.isNotEmpty == true) {
        print('File path: ${files?.path}');
        File file = File(files?.path ?? "");
        List<int> fileBytes = await file.readAsBytes();
        String fieldName = '';

        if (files.type.startsWith("image/")) {
          fieldName = 'post_image';
        } else if (files.type.startsWith("video/")) {
          fieldName = 'post_video';
        } else if (files.type.startsWith("audio/")) {
          fieldName = 'post_audio';
        } else {
          // Handle other file types if needed
          return;
        }

        // Add the file as bytes to the form data
        formData.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            fileBytes,
            filename: 'post_$fieldName.${files.type.split('/').last}',
          ),
        );
      }

      // Set authorization header
      formData.headers['Authorization'] = 'Token $authToken';

      // Clear form fields after submitting
      setState(() {
        post = "";
        files = FileType(
          path: "",
          lastModified: 0,
          lastModifiedDate: DateTime.now(),
          name: "",
          size: 0,
          type: "",
          webkitRelativePath: "",
        );
        previewUrl = null;
        error = "";
        isOpen = false;
      });

      try {
        final response = await formData.send();
        if (response.statusCode == 201) {
          // Handle success, e.g., show a success message to the user
          print('Post created successfully');

          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeFeeds(),
            ),
          );
          postController.clear();
        } else {
          // Handle error
          print('Error creating post. Status code: ${response.statusCode}');
        }
      } catch (error) {
        // Handle error
        print('Error creating post: $error');
      }
    }
  }

  // Future<void> handleSubmit() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? tokenString = prefs.getString('token');

  //   if (tokenString != null) {
  //     Map<String, dynamic> tokenMap = json.decode(tokenString);
  //     String? authToken = tokenMap['auth_token'];

  //     final formData = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('${ApiConfig.baseUrl}/api/posts'),
  //     );

  //     formData.fields.addAll({
  //       "post_content": post,
  //       "like": false.toString(),
  //     });

  //     // Add media file if selected
  //     // if (files.path.isNotEmpty) {
  //     //   File file = File(files.path);
  //     //   List<int> fileBytes = await file.readAsBytes();
  //     //   String fieldName = 'post_image';

  //     //   if (isImage == "image") {
  //     //     fieldName = 'post_image';
  //     //   } else if (isImage == "video") {
  //     //     fieldName = 'post_video';
  //     //   } else if (isImage == "audio") {
  //     //     fieldName = 'post_audio';
  //     //   } else {
  //     //     // Handle other cases if needed
  //     //     return;
  //     //   }

  //     //   // Add the file as bytes to the form data
  //     //   // formData.files.add(
  //     //   //   http.MultipartFile.fromBytes(fieldName, fileBytes,
  //     //   //       filename: files.name),
  //     //   // );
  //     //   formData.files.add(
  //     //     http.MultipartFile.fromBytes(
  //     //       fieldName,
  //     //       fileBytes,
  //     //       filename: 'post_image.${files.type.split('/').last}',
  //     //     ),
  //     //   );
  //     // }

  //     if (files?.path.isNotEmpty == true) {
  //       print('File path: ${files?.path}');
  //       File file = File(files?.path ?? "");
  //       List<int> fileBytes = await file.readAsBytes();
  //       String fieldName = 'post_image';

  //       if (isImage == "image") {
  //         fieldName = 'post_image';
  //       } else if (isImage == "video") {
  //         fieldName = 'post_video';
  //       } else if (isImage == "audio") {
  //         fieldName = 'post_audio';
  //       } else {
  //         // Handle other cases if needed
  //         return;
  //       }

  //       // Add the file as bytes to the form data
  //       formData.files.add(
  //         http.MultipartFile.fromBytes(
  //           fieldName,
  //           fileBytes,
  //           filename: 'post_$isImage.${files.type.split('/').last}',
  //         ),
  //       );
  //       print('Added file to formData: ${formData.files}');
  //     }

  //     // Set authorization header
  //     formData.headers['Authorization'] = 'Token $authToken';

  //     // Clear form fields after submitting
  //     setState(() {
  //       post = "";
  //       files = FileType(
  //         path: "",
  //         lastModified: 0,
  //         lastModifiedDate: DateTime.now(),
  //         name: "",
  //         size: 0,
  //         type: "",
  //         webkitRelativePath: "",
  //       );
  //       previewUrl = null;
  //       error = "";
  //       isOpen = false;
  //     });

  //     try {
  //       final response = await formData.send();
  //       if (response.statusCode == 201) {
  //         // Handle success, e.g., show a success message to the user
  //         print('Post created successfully');

  //         Navigator.popUntil(context, (route) => route.isFirst);
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => HomeFeeds(),
  //           ),
  //         );
  //         postController.clear();
  //       } else {
  //         // Handle error
  //         print('Error creating post. Status code: ${response.statusCode}');
  //       }
  //     } catch (error) {
  //       // Handle error
  //       print('Error creating post: $error');
  //     }
  //   }
  // }

  String handleText() {
    if (files.type.startsWith("image/")) {
      return "image";
    } else if (files.type.startsWith("video/")) {
      return "video";
    } else if (files.type.startsWith("audio/")) {
      return "audio";
    } else {
      return "file";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      width: double.infinity,
      child: Column(
        children: [
          Form(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: postController,
                      onChanged: (value) => handleChange(value),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "What's on your mind...",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (error.isNotEmpty)
                    Text(error, style: TextStyle(color: Colors.red)),
                  if (isOpen)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: handleDrop,
                        child: Text("Pick File"),
                      ),
                    ),
                  if (previewUrl != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      child: previewUrl is MemoryImage
                          ? Image.memory(Uint8List.fromList(
                              (previewUrl as MemoryImage).bytes))
                          : previewUrl is String
                              ? (files.type.startsWith("image/")
                                  ? Image.network(previewUrl)
                                  : VideoPlayerWidget(previewUrl))
                              : Container(),
                    ),
                  // Action Buttons Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButtons(Icons.image, "Image", handleImage),
                      _buildActionButtons(Icons.videocam, "Video", handleVideo),
                      _buildActionButtons(
                          Icons.audiotrack, "Audio", handleAudio),
                      ElevatedButton(
                        onPressed: handleSubmit,
                        child: Text("Post"),
                        style: ElevatedButton.styleFrom(
                          // primary: Colors.blue,
                          // onPrimary: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      IconData icon, String label, Function() onPressed) {
    return InkWell(
      onTap: () {
        // Call handleDrop directly when tapping on the icon
        if (label == "Image" || label == "Video" || label == "Audio") {
          onPressed();
        }
      },
      child: Column(
        children: [
          Icon(icon, size: 32),
          SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
