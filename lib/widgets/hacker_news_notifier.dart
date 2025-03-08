import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

final dioProvider = Provider((ref) => Dio());

final hackerNewsProvider =
    StateNotifierProvider<HackerNewsNotifier, List<Map<String, dynamic>>>((
      ref,
    ) {
      return HackerNewsNotifier(ref, []);
    });

class HackerNewsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  HackerNewsNotifier(this.ref, List<int> ids) : super([]) {
    _allIds = ids;
    fetchNextBatch();
  }

  final Ref ref;
  int _page = 0;
  final int _pageSize = 10;
  List<int> _allIds = [];
  bool _isLoading = false;

  Future<void> fetchNextBatch() async {
    if (_isLoading || _page * _pageSize >= _allIds.length) return;
    _isLoading = true;

    final ids = _allIds.skip(_page * _pageSize).take(_pageSize).toList();
    final futures = ids.map(
      (id) async => await ref
          .read(dioProvider)
          .get("https://hacker-news.firebaseio.com/v0/item/$id.json"),
    );
    final responses = await Future.wait(futures);

    final newData =
        responses.map((r) => r.data as Map<String, dynamic>).toList();
    state = [...state, ...newData];
    _page++;
    _isLoading = false;
  }
}

class HackerNewsList extends ConsumerStatefulWidget {
  final List<int> ids;
  final bool showProfileButton;

  const HackerNewsList({
    super.key,
    required this.ids,
    this.showProfileButton = true,
  });

  @override
  ConsumerState<HackerNewsList> createState() => _HackerNewsListState();
}

class _HackerNewsListState extends ConsumerState<HackerNewsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(hackerNewsProvider.notifier)._allIds = widget.ids;
    ref.read(hackerNewsProvider.notifier).fetchNextBatch();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      ref.read(hackerNewsProvider.notifier).fetchNextBatch();
    }
  }

  void _openUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  void _onProfileTap(String author) {
    context.push('/author/$author');
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(hackerNewsProvider);
    final isLoading = ref.watch(hackerNewsProvider.notifier)._isLoading;

    return Stack(
      children: [
        if (posts.isEmpty)
          FutureBuilder(
            future: Future.delayed(const Duration(seconds: 3)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (posts.isEmpty) {
                return const Center(child: Text("There is no available posts"));
              }
              return const SizedBox();
            },
          )
        else
          ListView.builder(
            controller: _scrollController,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final time = DateTime.fromMillisecondsSinceEpoch(
                post['time'] * 1000,
              );
              final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(time);
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading:
                        widget.showProfileButton
                            ? GestureDetector(
                              onTap: () => _onProfileTap(post['by']),
                              child: const Icon(
                                Icons.person,
                                color: Colors.black54,
                              ),
                            )
                            : null,
                    title: Text(post['title'] ?? 'No Title'),
                    subtitle: Text('By ${post['by']} · $formattedTime'),
                    onTap: () {
                      if (post['url'] != null) {
                        _openUrl(post['url']);
                      } else {
                        toastification.show(
                          title: const Text("No link available for this item"),
                          type: ToastificationType.error,
                          autoCloseDuration: const Duration(seconds: 3),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        if (isLoading && posts.isNotEmpty)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
