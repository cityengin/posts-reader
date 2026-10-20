import 'package:posts_reader/core/error/failure.dart';
import 'package:posts_reader/features/posts/domain/entities/post.dart';

/// Hợp đồng truy xuất bài viết mà tầng Domain cần.
///
/// Domain chỉ khai báo interface, tầng Data sẽ implement (gọi HTTP tới
/// JSONPlaceholder). Nhờ đảo ngược phụ thuộc như vậy, UseCase không biết gì
/// về HTTP và có thể test bằng mock.
///
/// Khi thất bại, các phương thức ném một [Failure] thay vì trả về `Either`.
abstract class PostRepository {
  /// Lấy toàn bộ danh sách bài viết.
  ///
  /// Ném [NetworkFailure] hoặc [ServerFailure] khi thất bại.
  Future<List<Post>> getPosts();

  /// Lấy bài viết có mã [id].
  ///
  /// Ném [NotFoundFailure] nếu bài viết không tồn tại, [NetworkFailure] hoặc
  /// [ServerFailure] với các lỗi còn lại.
  Future<Post> getPostById(int id);
}
