import 'package:posts_reader/core/error/failure.dart';
import 'package:posts_reader/features/posts/domain/entities/post.dart';
import 'package:posts_reader/features/posts/domain/repositories/post_repository.dart';

/// UseCase lấy chi tiết một bài viết theo id.
class GetPostById {
  // Nhận repository qua constructor, cùng lý do với GetPosts.
  const GetPostById(this._repository);

  final PostRepository _repository;

  /// Trả về bài viết có mã [id].
  ///
  /// [Failure] từ repository (ví dụ [NotFoundFailure]) được ném tiếp lên
  /// tầng Presentation.
  Future<Post> call(int id) => _repository.getPostById(id);
}
