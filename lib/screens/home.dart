import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:hackernews/widgets/hacker_news_notifier.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  List<int> _ids = [];

  @override
  void initState() {
    super.initState();
    _fetchIds();
  }

  Future<void> _fetchIds() async {
    final response = await Dio().get<List<dynamic>>(
      'https://hacker-news.firebaseio.com/v0/topstories.json',
    );
    setState(() {
      _ids = List<int>.from(response.data!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hacker News')),
      body: Column(
        children: [
          Expanded(
            child:
                _ids.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : HackerNewsList(ids: _ids, showProfileButton: true),
          ),
        ],
      ),
    );
  }
}
