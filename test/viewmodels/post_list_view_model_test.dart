import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:posts_reader/models/post.dart';
import 'package:posts_reader/services/api_exception.dart';
import 'package:posts_reader/services/post_service.dart';
import 'package:posts_reader/viewmodels/base_view_model.dart';
import 'package:posts_reader/viewmodels/post_list_view_model.dart';

// Service giả: mỗi test gán onFetchPosts để quyết định kết quả trả về, không
// gọi mạng.
class FakePostService implements PostService {
  Future<List<Post>> Function() onFetchPosts = () async => const [];
  int fetchPostsCallCount = 0;

  @override
  Future<List<Post>> fetchPosts() {
    fetchPostsCallCount++;
    return onFetchPosts();
  }

  @override
  Future<Post> fetchPostById(int id) => throw UnimplementedError();
}

void main() {
  late FakePostService service;
  late PostListViewModel viewModel;
  late List<LoadStatus> notifiedStatuses;

  const posts = [
    Post(id: 1, userId: 1, title: 'Tiêu đề 1', body: 'Nội dung 1'),
    Post(id: 2, userId: 1, title: 'Tiêu đề 2', body: 'Nội dung 2'),
  ];

  setUp(() {
    service = FakePostService();
    viewModel = PostListViewModel(service);
    notifiedStatuses = [];
    viewModel.addListener(() => notifiedStatuses.add(viewModel.status));
  });

  test('load thành công: status loading → success và posts đúng', () async {
    expect(
      service.fetchPostsCallCount,
      0,
      reason: 'constructor không gọi mạng',
    );
    expect(viewModel.status, LoadStatus.loading);

    service.onFetchPosts = () async => posts;
    await viewModel.load();

    expect(notifiedStatuses, [LoadStatus.loading, LoadStatus.success]);
    expect(viewModel.posts, posts);
    expect(viewModel.errorMessage, isNull);
    expect(() => viewModel.posts.add(posts.first), throwsUnsupportedError);
  });

  test(
    'service ném lỗi server → status error, message đúng, canRetry = true',
    () async {
      service.onFetchPosts = () async => throw const ApiException.server(500);

      await viewModel.load();

      expect(notifiedStatuses, [LoadStatus.loading, LoadStatus.error]);
      expect(viewModel.errorMessage, 'Máy chủ trả về lỗi (mã 500).');
      expect(viewModel.canRetry, isTrue);
      expect(viewModel.posts, isEmpty);
    },
  );

  test('sau khi lỗi, gọi lại load() thì thành công', () async {
    service.onFetchPosts = () async => throw const ApiException.network();
    await viewModel.load();
    expect(viewModel.status, LoadStatus.error);

    service.onFetchPosts = () async => posts;
    await viewModel.load();

    expect(viewModel.status, LoadStatus.success);
    expect(viewModel.posts, posts);
    expect(viewModel.errorMessage, isNull);
    expect(service.fetchPostsCallCount, 2);
  });

  test(
    'dispose trong lúc đang tải rồi request hoàn tất thì không ném lỗi',
    () async {
      final pendingRequest = Completer<List<Post>>();
      service.onFetchPosts = () => pendingRequest.future;

      final loading = viewModel.load();
      viewModel.dispose();
      pendingRequest.complete(posts);

      await expectLater(loading, completes);
    },
  );
}
