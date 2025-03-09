import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackernews/screens/author_posts_screen.dart';
import 'package:hackernews/screens/author_screen.dart';
import 'package:hackernews/screens/topnews_screen.dart';
import 'package:toastification/toastification.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => TopNews('/'),
    ),

    GoRoute(
      path: '/author/:author',
      builder: (context, state) {
        final author = state.pathParameters['author'];

        if (author == null || author.isEmpty) {
          toastification.show(
            title: const Text("Author not found"),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 3),
          );
          return TopNews('/');
        }
        
        return Author(authorName: author);
      },
    ),

    GoRoute(
      path: '/author/:author/:authorsPostsArray',
      builder: (context, state) {
        final author = state.pathParameters['author'];
        final authorsPostsArray = state.pathParameters['authorsPostsArray'];

        if (author == null || author.isEmpty || authorsPostsArray == null || authorsPostsArray.isEmpty) {
          toastification.show(
            title: const Text("Can't find all authors posts"),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 3),
          );
          return Container();
        }
        
        return AuthorPosts(authorName: author, authorPostsArray: authorsPostsArray);
      },
    ),
  ],
);