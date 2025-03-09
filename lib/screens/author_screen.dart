import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';

class Author extends StatefulWidget {
  final String authorName;

  const Author({super.key, required this.authorName});

  @override
  AuthorState createState() => AuthorState();
}

class AuthorState extends State<Author> {
  late Future<Map<String, dynamic>> authorData;

  @override
  void initState() {
    super.initState();
    authorData = fetchAuthorData(widget.authorName);
  }

  Future<Map<String, dynamic>> fetchAuthorData(String authorName) async {
    final dio = Dio();
    final url = 'https://hacker-news.firebaseio.com/v0/user/$authorName.json';
    try {
      final response = await dio.get(url);
      return response.data;
    } catch (e) {
      throw Exception('Failed to load author data');
    }
  }

  String parseHtmlContent(String content) {
    final document = parse(content);
    return document.body?.text ?? content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.authorName)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: authorData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found.'));
          }

          final data = snapshot.data!;
          final createdTimestamp = DateTime.fromMillisecondsSinceEpoch(data['created'] * 1000);
          final formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm').format(createdTimestamp);
          final about = data['about'] ?? 'No about section available';
          final parsedAbout = parseHtmlContent(about);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Created: $formattedTimestamp', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('About: $parsedAbout', style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
