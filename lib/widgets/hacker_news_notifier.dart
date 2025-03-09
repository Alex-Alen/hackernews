import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

// Dio provider for network requests
final dioProvider = Provider((ref) => Dio());

// StateNotifierProvider for managing Hacker News data
final hackerNewsProvider = StateNotifierProvider<HackerNewsNotifier, List<Map<String, dynamic>>>((ref) {
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

  // Reset the state with new IDs
  void reset(List<int> newIds) {
    _page = 0;
    _allIds = newIds;
    state = [];
    fetchNextBatch();
  }

  // Fetch the next batch of posts
  Future<void> fetchNextBatch() async {
    if (_isLoading || _page * _pageSize >= _allIds.length) return;
    _isLoading = true;

    final ids = _allIds.skip(_page * _pageSize).take(_pageSize).toList();
    final futures = ids.map((id) async {
      final response = await ref.read(dioProvider).get("https://hacker-news.firebaseio.com/v0/item/$id.json");
      return response.data as Map<String, dynamic>;
    });

    final newData = await Future.wait(futures);
    state = [...state, ...newData];
    _page++;
    _isLoading = false;
  }
}

class HackerNewsList extends ConsumerStatefulWidget {
  final List<int> ids;

  const HackerNewsList({
    super.key,
    required this.ids,
  });

  @override
  ConsumerState<HackerNewsList> createState() => _HackerNewsListState();
}

class _HackerNewsListState extends ConsumerState<HackerNewsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(hackerNewsProvider.notifier).reset(widget.ids);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Handle scroll events to load more data
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      ref.read(hackerNewsProvider.notifier).fetchNextBatch();
    }
  }

  // Open a URL in the browser
  void _openUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      toastification.show(
        title: const Text("Could not launch the URL"),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(hackerNewsProvider);
    final isLoading = ref.read(hackerNewsProvider.notifier)._isLoading;

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final time = DateTime.fromMillisecondsSinceEpoch(post['time'] * 1000);
            final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(time);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
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