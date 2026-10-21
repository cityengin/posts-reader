import 'dart:async';

import 'package:posts_reader/models/post.dart';
import 'package:posts_reader/services/post_service.dart';

/// Service giả dùng cho widget test ở tầng View, không gọi mạng thật.
class FakePostService implements PostService {
  Future<List<Post>> Function() onFetchPosts = () async => const [];
  Future<Post> Function(int id) onFetchPostById = (_) async =>
      throw UnimplementedError();

  int fetchPostsCallCount = 0;
  final requestedIds = <int>[];

  @override
  Future<List<Post>> fetchPosts() {
    fetchPostsCallCount++;
    return onFetchPosts();
  }

  @override
  Future<Post> fetchPostById(int id) {
    requestedIds.add(id);
    return onFetchPostById(id);
  }
}
