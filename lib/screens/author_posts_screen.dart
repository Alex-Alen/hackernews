import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hackernews/widgets/news_list.dart';

class AuthorPosts extends StatelessWidget {
  final String authorName;
  final String authorPostsArray;
  const AuthorPosts({
    super.key,
    required this.authorName,
    required this.authorPostsArray,
  });

  @override
  Widget build(BuildContext context) {
    List<int> postIds = List<int>.from(jsonDecode(authorPostsArray));
    return Scaffold(
      appBar: AppBar(title: Text("$authorName's posts")),
      body: NewsList(postIds: postIds, isUsersPost: true,),
    );
  }
}
