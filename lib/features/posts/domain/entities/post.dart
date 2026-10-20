/// Bài viết: đối tượng nghiệp vụ cốt lõi của tính năng posts.
///
/// Chỉ chứa dữ liệu, không có `fromJson`/`toJson`: parse JSON từ
/// JSONPlaceholder là việc của tầng Data, Domain không cần biết dữ liệu
/// đến từ đâu.
///
/// Immutable nhờ mọi field đều `final` và constructor `const`. Không dùng
/// annotation `@immutable` vì nó nằm trong package ngoài (meta/flutter).
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  // So sánh theo giá trị thay vì theo tham chiếu, để hai Post cùng dữ liệu
  // được coi là bằng nhau. Viết tay thay vì dùng equatable để Domain không
  // phụ thuộc package ngoài.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          other.id == id &&
          other.userId == userId &&
          other.title == title &&
          other.body == body;

  @override
  int get hashCode => Object.hash(id, userId, title, body);

  @override
  String toString() => 'Post(id: $id, userId: $userId, title: $title)';
}
