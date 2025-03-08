import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

final dioProvider = Provider((ref) => Dio());

final hackerNewsProvider =
    StateNotifierProvider<HackerNewsNotifier, List<Map<String, dynamic>>>((
      ref,
    ) {
      return HackerNewsNotifier(ref);
    });

class HackerNewsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  HackerNewsNotifier(this.ref) : super([]);
  final Ref ref;
  int _page = 0;
  final int _pageSize = 10;
  List<int> _allIds = [];
  bool _isLoading = false;

  Future<void> fetchIds(String endpoint) async {
    if (_allIds.isEmpty) {
      final response = await ref.read(dioProvider).get<List<dynamic>>(endpoint);
      _allIds = List<int>.from(response.data!);
    }
    fetchNextBatch();
  }

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
  final String endpoint;
  const HackerNewsList({super.key, required this.endpoint});

  @override
  ConsumerState<HackerNewsList> createState() => _HackerNewsListState();
}

class _HackerNewsListState extends ConsumerState<HackerNewsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(hackerNewsProvider.notifier).fetchIds(widget.endpoint);
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

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(hackerNewsProvider);
    return ListView.builder(
      controller: _scrollController,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final time = DateTime.fromMillisecondsSinceEpoch(post['time'] * 1000);
        final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(time);
        return Column(
          children: [
            ListTile(
              title: Text(post['title'] ?? 'No Title'),
              subtitle: Text('By ${post['by']} · $formattedTime'),
              onTap: () {
                if (post['url'] != null) {
                  _openUrl(post['url']);
                } else {
                  toastification.show(
                    title: Text("No link available for this item"),
                    type: ToastificationType.error,
                    autoCloseDuration: const Duration(seconds: 3),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
