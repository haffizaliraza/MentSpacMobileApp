import 'package:flutter/material.dart';
import 'register_page.dart';
import 'package:http/http.dart' as http;
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: LoginPage(),
  ));
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Future<void> loginUser(
      String email, String password, BuildContext context) async {
    final String apiUrl = 'http://mentspac.com:8000/api/auth/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        print('Login Successful');
        print('Response: ${response.body}');

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response.body);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
        );
      } else {
        print('Login Failed');
        print('Response: ${response.body}');

        // Display error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed. Please provide correct credentials.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error catch error: $error');

      // Display a generic error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

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
                          // Add your forgot password logic here
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
                    onPressed: () {
                      // Validate email and password before calling loginUser
                      if (emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Email and password are required.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        print('Email: ${emailController.text}');
                        print('Password: ${passwordController.text}');
                        loginUser(emailController.text, passwordController.text,
                            context);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      minimumSize: MaterialStateProperty.all<Size>(
                          const Size(double.infinity, 48)),
                    ),
                    child: const Text('Sign in',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print('Pressed Login with google');
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
}
