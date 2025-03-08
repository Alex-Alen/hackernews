import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackernews/router.dart';
import 'package:toastification/toastification.dart';

void main() {
  runApp(
    ProviderScope(
      child: ToastificationWrapper(
        child: MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
}
