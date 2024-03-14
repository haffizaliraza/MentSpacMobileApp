import 'package:flutter/material.dart';
import 'package:my_flutter_app/category_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
// import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  print('Token: $token');

  runApp(MaterialApp(
    home: token != null ? CategoryPage() : LoginPage(),
  ));
}
