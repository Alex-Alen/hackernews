import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsList extends StatefulWidget {
  final List<int> postIds;
  final bool isUsersPost;

  const NewsList({super.key, required this.postIds, required this.isUsersPost});

  @override
  NewsListState createState() => NewsListState();
}

class NewsListState extends State<NewsList> {
  final Dio _dio = Dio();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static const _pageSize = 10;

  late final PagingController<int, Map<String, dynamic>> _pagingController;

  @override
  void initState() {
    super.initState();

    _pagingController = PagingController<int, Map<String, dynamic>>(
      getNextPageKey:
          (state) =>
              (state.keys?.last ?? 0) + _pageSize < widget.postIds.length
                  ? (state.keys?.last ?? 0) + _pageSize
                  : null,
      fetchPage: (pageKey) => _fetchPage(pageKey),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchPage(int pageKey) async {
    try {
      final startIndex = pageKey;
      final endIndex = startIndex + _pageSize;
      final idsToFetch = widget.postIds.sublist(
        startIndex,
        endIndex.clamp(0, widget.postIds.length),
      );

      final newItems = <Map<String, dynamic>>[];
      for (var id in idsToFetch) {
        var response = await _dio.get(
          'https://hacker-news.firebaseio.com/v0/item/$id.json',
        );
        if (response.statusCode == 200) {
          newItems.add(response.data);
        }
      }

      return newItems;
    } catch (error) {
      _pagingController;
      return [];
    }
  }

  _openInBrowser(String url) async {
    await launchUrl(Uri.parse(url));
  }

  _openAuthorsPage(String authorName) {
    context.push('/author/$authorName');
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: _pagingController,
      builder:
          (
            context,
            state,
            fetchNextPage,
          ) => PagedListView<int, Map<String, dynamic>>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<Map<String, dynamic>>(
              itemBuilder: (context, post, index) {
                if (post['title'] == null ||
                    post['title'].toString().trim().isEmpty) {
                  return SizedBox.shrink(); // Skip rendering this item
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        if (!widget.isUsersPost) ...[
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () => _openAuthorsPage(post['by']),
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                        Expanded(
                          child: ListTile(
                            title: Text(post['title']),
                            subtitle: Text(
                              !widget.isUsersPost
                                  ? 'by ${post['by']} on ${_dateFormat.format(DateTime.fromMillisecondsSinceEpoch(post['time'] * 1000))}'
                                  : _dateFormat.format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      post['time'] * 1000,
                                    ),
                                  ),
                            ),
                            onTap: () {
                              _openInBrowser(post['url']);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
    );
  }
}
