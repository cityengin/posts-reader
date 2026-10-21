import 'package:posts_reader/models/post.dart';
import 'package:posts_reader/services/post_service.dart';
import 'package:posts_reader/viewmodels/base_view_model.dart';

/// ViewModel cho màn hình danh sách bài viết.
class PostListViewModel extends BaseViewModel {
  // Nhận service qua constructor thay vì tự tạo, để test truyền service giả.
  // Constructor không gọi mạng: View chủ động gọi load() khi cần.
  PostListViewModel(this._service);

  final PostService _service;
  List<Post> _posts = const [];

  /// Danh sách chỉ đọc: View không thể sửa trực tiếp, mọi thay đổi phải đi
  /// qua ViewModel.
  List<Post> get posts => _posts;

  /// Tải danh sách bài viết. Nút "Thử lại" của View cũng gọi lại hàm này.
  Future<void> load() => runLoad(() async {
    _posts = List.unmodifiable(await _service.fetchPosts());
  });
}
