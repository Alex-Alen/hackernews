import 'package:flutter/material.dart';
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
      body: Column(
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
                    padding: EdgeInsets.symmetric(horizontal: 7),
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
                            child: FutureBuilder<Map<String, dynamic>>(
                              future: fetchUserData(authorName),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    'Loading...',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    'Error fetching data',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  );
                                } else if (snapshot.hasData) {
                                  final userData = snapshot.data!;
                                  final creationDate = userData['created'];
                                  return Text(
                                    'Author since ${formatCreationDate(creationDate)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  );
                                } else {
                                  return Text(
                                    'No data available',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  );
                                }
                              },
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
          // Expanded(
          //   child: HackerNewsList(
          //     endpoint:
          //         'https://hacker-news.firebaseio.com/v0/user/$authorName.json',
          //     showProfileButton: false,
          //   ),
          // ),
        ],
      ),
    );
  }
}
