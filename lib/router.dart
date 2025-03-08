import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackernews/screens/author.dart';
import 'package:hackernews/screens/home.dart';
import 'package:toastification/toastification.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => Home()),
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
          return Home();
        }
        
        return Author(authorName: author);
      },
    ),
  ],
);
