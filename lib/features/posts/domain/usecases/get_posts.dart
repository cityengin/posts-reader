import 'package:posts_reader/core/error/failure.dart';
import 'package:posts_reader/features/posts/domain/entities/post.dart';
import 'package:posts_reader/features/posts/domain/repositories/post_repository.dart';

/// UseCase lấy danh sách bài viết.
///
/// Mỗi UseCase đại diện cho đúng một hành động nghiệp vụ. Hiện tại nó chỉ
/// chuyển tiếp tới repository, nhưng là chỗ đặt logic nghiệp vụ về sau mà
/// không phải sửa tầng Presentation.
class GetPosts {
  // Constructor injection: UseCase chỉ phụ thuộc vào abstraction
  // [PostRepository] và không tự tạo implementation. DI container sẽ truyền
  // implementation thật, còn test thì truyền mock.
  const GetPosts(this._repository);

  final PostRepository _repository;

  /// Trả về danh sách bài viết.
  ///
  /// Không bắt lỗi ở đây: [Failure] từ repository được ném tiếp lên để tầng
  /// Presentation quyết định cách hiển thị. Đặt tên `call` để có thể gọi
  /// UseCase như một hàm: `getPosts()`.
  Future<List<Post>> call() => _repository.getPosts();
}
