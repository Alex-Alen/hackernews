import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackernews/widgets/hacker_news_notifier.dart';
import 'package:toastification/toastification.dart';

void main() {
  runApp(
    ProviderScope(
      child: ToastificationWrapper(
        child: MaterialApp(
          home: const MyApp(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hacker News')),
      body: Column(
        children: [
          Expanded(
            child: HackerNewsList(
              endpoint: 'https://hacker-news.firebaseio.com/v0/topstories.json',
              showProfileButton: false,
            ),
          ),
        ],
      ),
    );
  }
}
