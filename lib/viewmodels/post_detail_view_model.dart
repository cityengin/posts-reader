import 'package:posts_reader/models/post.dart';
import 'package:posts_reader/services/post_service.dart';
import 'package:posts_reader/viewmodels/base_view_model.dart';

/// ViewModel cho màn hình chi tiết một bài viết.
class PostDetailViewModel extends BaseViewModel {
  // Nhận service qua constructor như PostListViewModel; constructor không gọi
  // mạng.
  PostDetailViewModel(this._service, this._postId);

  final PostService _service;
  final int _postId;
  Post? _post;

  /// Bài viết đã tải, null khi chưa tải xong hoặc tải lỗi.
  Post? get post => _post;

  /// Tải bài viết. Nút "Thử lại" của View cũng gọi lại hàm này.
  Future<void> load() => runLoad(() async {
    _post = await _service.fetchPostById(_postId);
  });
}
