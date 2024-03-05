import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    // Fetch the id using whatever logic you have
    // For now, assigning a placeholder value
    id = "some_id";
  }

  Future<void> validateFileType(FileType files) async {
    if (files.path.isEmpty) {
      setState(() {
        error = "Invalid file type selected";
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

    late ByteData byteData;
    try {
      byteData = await rootBundle.load(files.path);
    } catch (e) {
      setState(() {
        error = "Invalid file type selected";
      });
      return;
    }

    Uint8List uint8List = byteData.buffer.asUint8List();

    if (validImageTypes.contains(files.type)) {
      setState(() {
        previewUrl = MemoryImage(uint8List);
      });
    } else if (validVideoTypes.contains(files.type)) {
      // Handle video preview
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
          path: result.files.single.path ?? "",
          lastModified: DateTime.now().millisecondsSinceEpoch,
          lastModifiedDate: DateTime.now(),
          name: result.files.single.name,
          size: result.files.single.size,
          type: mime(result.files.single.path) ?? "",
          webkitRelativePath: "",
        );
        error = "";
      });

      validateFileType(files);
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

  // Future<void> handleSubmit() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? tokenString = prefs.getString('token');

  //   if (tokenString != null) {
  //     Map<String, dynamic> tokenMap = json.decode(tokenString);
  //     String? authToken = tokenMap['auth_token'];

  //     final formData = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('http://mentspac.com/api/posts'),
  //     );

  //     formData.fields.addAll({
  //       "post_content": post,
  //       "like": false.toString(),
  //     });

  //     // if (isImage == "image") {
  //     //   if (files.path.isNotEmpty) {
  //     //     // Read the file as bytes
  //     //     Uint8List fileBytes = await html.File(files.path).readAsBytes();

  //     //     // Add the file as bytes to the form data
  //     //     formData.files.add(
  //     //       http.MultipartFile.fromBytes('post_image', fileBytes,
  //     //           filename: files.name),
  //     //     );
  //     //   }
  //     // } else if (isImage == "video") {
  //     //   if (files.path.isNotEmpty) {
  //     //     Uint8List fileBytes = await html.File(files.path).readAsBytes();
  //     //     formData.files.add(
  //     //       http.MultipartFile.fromBytes('post_video', fileBytes,
  //     //           filename: files.name),
  //     //     );
  //     //   }
  //     // } else if (isImage == "audio") {
  //     //   if (files.path.isNotEmpty) {
  //     //     Uint8List fileBytes = await html.File(files.path).readAsBytes();
  //     //     formData.files.add(
  //     //       http.MultipartFile.fromBytes('post_audio', fileBytes,
  //     //           filename: files.name),
  //     //     );
  //     //   }
  //     // }

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
  //       if (response.statusCode == 200) {
  //         // Handle success, e.g., show a success message to the user
  //         print('Post created successfully');
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

  Future<void> handleSubmit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenString = prefs.getString('token');

    if (tokenString != null) {
      Map<String, dynamic> tokenMap = json.decode(tokenString);
      String? authToken = tokenMap['auth_token'];

      final formData = http.MultipartRequest(
        'POST',
        Uri.parse('http://mentspac.com/api/posts'),
      );

      formData.fields.addAll({
        "post_content": post,
        "like": false.toString(),
      });

      // if (isImage == "image" && files.path.isNotEmpty) {
      //   // Read the file as bytes
      //   Uint8List fileBytes = await html.File(files.path).readAsBytes();

      //   // Add the file as bytes to the form data
      //   formData.files.add(
      //     http.MultipartFile.fromBytes('post_image', fileBytes,
      //         filename: files.name),
      //   );
      // } else if (isImage == "video" && files.path.isNotEmpty) {
      //   Uint8List fileBytes = await html.File(files.path).readAsBytes();
      //   formData.files.add(
      //     http.MultipartFile.fromBytes('post_video', fileBytes,
      //         filename: files.name),
      //   );
      // } else if (isImage == "audio" && files.path.isNotEmpty) {
      //   Uint8List fileBytes = await html.File(files.path).readAsBytes();
      //   formData.files.add(
      //     http.MultipartFile.fromBytes('post_audio', fileBytes,
      //         filename: files.name),
      //   );
      // }

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
        if (response.statusCode == 200) {
          // Handle success, e.g., show a success message to the user
          print('Post created successfully');
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
                      controller: TextEditingController(text: post),
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
                              ? Image.network(previewUrl)
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
      onTap: onPressed,
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
