import 'package:flutter_test/flutter_test.dart';
import 'package:posts_reader/models/post.dart';
import 'package:posts_reader/services/api_exception.dart';
import 'package:posts_reader/services/post_service.dart';
import 'package:posts_reader/viewmodels/base_view_model.dart';
import 'package:posts_reader/viewmodels/post_detail_view_model.dart';

// Service giả: mỗi test gán onFetchPostById để quyết định kết quả trả về,
// đồng thời ghi lại id được yêu cầu.
class FakePostService implements PostService {
  Future<Post> Function(int id) onFetchPostById = (_) async =>
      throw UnimplementedError();
  final requestedIds = <int>[];

  @override
  Future<Post> fetchPostById(int id) {
    requestedIds.add(id);
    return onFetchPostById(id);
  }

  @override
  Future<List<Post>> fetchPosts() => throw UnimplementedError();
}

void main() {
  late FakePostService service;

  const post = Post(id: 7, userId: 1, title: 'Tiêu đề 7', body: 'Nội dung 7');

  setUp(() {
    service = FakePostService();
  });

  test('load thành công: status success và post đúng', () async {
    service.onFetchPostById = (_) async => post;
    final viewModel = PostDetailViewModel(service, 7);

    await viewModel.load();

    expect(viewModel.status, LoadStatus.success);
    expect(viewModel.post, post);
    expect(service.requestedIds, [7]);
  });

  test('bài viết không tồn tại → status error và canRetry = false', () async {
    service.onFetchPostById = (_) async => throw const ApiException.notFound();
    final viewModel = PostDetailViewModel(service, 9999);

    await viewModel.load();

    expect(viewModel.status, LoadStatus.error);
    expect(viewModel.errorMessage, 'Không tìm thấy bài viết.');
    expect(viewModel.canRetry, isFalse);
    expect(viewModel.post, isNull);
  });
}
