import 'package:flutter/material.dart';
import 'package:hackernews/widgets/hacker_news_notifier.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

class Author extends StatelessWidget {
  final String authorName;
  const Author({super.key, required this.authorName});

  String get capitalizedAuthorName {
    if (authorName.isEmpty) return "";
    return authorName[0].toUpperCase() + authorName.substring(1);
  }

  String formatCreationDate(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  Future<Map<String, dynamic>> fetchUserData(String authorName) async {
    Dio dio = Dio();
    final response = await dio.get(
      'https://hacker-news.firebaseio.com/v0/user/$authorName.json',
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Author's Page")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(authorName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching user data'));
          } else if (snapshot.hasData) {
            final userData = snapshot.data!;
            final creationDate = userData['created'];
            final submittedIds = userData['submitted'] as List<dynamic>? ?? [];
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    height: 45,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(Icons.person, color: Colors.black54),
                        ),
                        Text(
                          capitalizedAuthorName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black54,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: Colors.white,
                            ),
                            height: 28,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(
                                    formatCreationDate(creationDate),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: HackerNewsList(
                    showProfileButton: false,
                    ids: submittedIds.cast<int>(),
                    resetIds: () {
                      ref
                          .read(hackerNewsProvider.notifier)
                          .reset(submittedIds.cast<int>());
                    },
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
