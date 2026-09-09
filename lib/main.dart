import 'package:flutter/material.dart';

import 'feature/chat/chat_page.dart';

void main() {
  runApp(const AgoraDemoApp());
}

class AgoraDemoApp extends StatelessWidget {
  const AgoraDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agora Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ChatPage(),
    );
  }
}
