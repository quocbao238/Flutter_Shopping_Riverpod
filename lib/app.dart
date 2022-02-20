import 'package:flutter/material.dart';
import 'package:flutter_shopping_riverpod/page/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Flutter Shopping Riverpod",
      home: HomePage(),
    );
  }
}
