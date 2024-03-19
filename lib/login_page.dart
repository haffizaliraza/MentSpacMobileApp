import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_flutter_app/category_page.dart';
import 'register_page.dart';
import 'package:http/http.dart' as http;
import 'forgotPassword_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_token.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Sign in to your account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Email',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (emailController.text.isEmpty ||
                                passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Email and password are required.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              print('Email: ${emailController.text}');
                              print('Password: ${passwordController.text}');
                              loginUser(emailController.text,
                                  passwordController.text, context);
                            }
                          },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          _isLoading ? Colors.grey : Colors.blue),
                      minimumSize: MaterialStateProperty.all<Size>(
                          const Size(double.infinity, 48)),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Sign in',
                            style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      signInWithGoogle(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      minimumSize: MaterialStateProperty.all<Size>(
                          const Size(double.infinity, 48)),
                    ),
                    child: const Text('Login with Google',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account yet? ",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          // Successful Google sign-in
          print('Google sign-in successful! User: ${user.displayName}');

          // Show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google Sign-In Successful!'),
              backgroundColor: Colors.green,
            ),
          );

          // TODO: Implement your logic after successful sign-in
        } else {
          // Google sign-in failed
          print('Google sign-in failed');

          // Show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google Sign-In Failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      // Handle errors
      print('Error during Google sign-in: $error');

      // Show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during Google Sign-In. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> loginUser(
      String email, String password, BuildContext context) async {
    // Set _isLoading to true when login process starts
    setState(() {
      _isLoading = true;
    });

    final String apiUrl = 'http://localhost:8000/api/auth/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        print('Login Successful');
        print('Response: ${response.body}');

        final Map<String, dynamic> responseData = json.decode(response.body);
        final UserToken userToken = UserToken.fromJson(responseData);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', json.encode(userToken.toJson()));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CategoryPage()),
        );
      } else {
        print('Login Failed');
        print('Response: ${response.body}');

        final dynamic responseBody = response.body;

        if (responseBody is String) {
          try {
            final Map<String, dynamic> errorData = json.decode(responseBody);

            if (errorData.containsKey('error')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorData['error']),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              showGenericErrorSnackbar(context);
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseBody),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          showGenericErrorSnackbar(context);
        }
      }
    } catch (error) {
      print('Error catch error: $error');
      showGenericErrorSnackbar(context);
    } finally {
      // Set _isLoading to false when login process ends (whether success or failure)
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showGenericErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred. Please try again later.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
