import 'package:flutter/material.dart';

void main() {
  runApp(const OutlineApp());
}

class OutlineApp extends StatelessWidget {
  const OutlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outline',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const EditorScreen(),
    );
  }
}

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Outline'),
      ),
    );
  }
}
