/// Một bài viết của JSONPlaceholder.
///
/// Model chỉ dùng thư viện Dart thuần, không phụ thuộc giao diện hay cách gọi
/// mạng, nên dùng lại và test độc lập được.
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// Tạo [Post] từ một object JSON của API.
  ///
  /// Đây là nơi duy nhất trong app chuyển JSON thành [Post]. Cố ý không bắt
  /// lỗi ở đây: JSON thiếu field hoặc sai kiểu sẽ ném [TypeError], tầng
  /// service bắt và đổi thành lỗi parse.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  final int id;
  final int userId;
  final String title;
  final String body;

  // So sánh theo giá trị để hai Post cùng dữ liệu được coi là bằng nhau
  // (thuận tiện khi test), viết tay để không cần package ngoài.
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
