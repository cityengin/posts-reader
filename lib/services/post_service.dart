import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:posts_reader/models/post.dart';
import 'package:posts_reader/services/api_exception.dart';

/// Network Service: gọi REST API JSONPlaceholder và trả về model [Post].
///
/// Không phụ thuộc Flutter và không giữ trạng thái giao diện, nên ViewModel
/// nào cũng dùng lại được và test được độc lập.
class PostService {
  // Tiêm http.Client qua constructor để test thay bằng MockClient, không cần
  // gọi mạng thật. `this._baseUrl` giữ field private nhưng người gọi vẫn
  // truyền tham số tên `baseUrl:`.
  PostService({
    http.Client? client,
    this._baseUrl = 'https://jsonplaceholder.typicode.com',
  }) : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 10);

  final http.Client _client;
  final String _baseUrl;

  /// Lấy toàn bộ danh sách bài viết từ `/posts`.
  ///
  /// Ném [ApiException] khi thất bại.
  Future<List<Post>> fetchPosts() => _get(
    '/posts',
    (json) => (json as List<dynamic>)
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  /// Lấy bài viết có mã [id] từ `/posts/{id}`.
  ///
  /// Ném [ApiException] loại [ApiErrorType.notFound] nếu bài viết không tồn
  /// tại, các loại khác khi thất bại vì lý do còn lại.
  Future<Post> fetchPostById(int id) =>
      _get('/posts/$id', (json) => Post.fromJson(json as Map<String, dynamic>));

  // Gom gọi GET, kiểm tra status và giải mã vào một chỗ để mọi lỗi đều được
  // đổi thành ApiException theo cùng một quy tắc.
  Future<T> _get<T>(String path, T Function(Object? json) decode) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl$path'))
          .timeout(_timeout);

      final statusCode = response.statusCode;
      if (statusCode == 404) {
        throw const ApiException.notFound();
      }
      if (statusCode < 200 || statusCode > 299) {
        throw ApiException.server(statusCode);
      }

      // Giải mã UTF-8 từ bytes thay vì dùng response.body: body chỉ mặc định
      // UTF-8 khi Content-Type là application/json, còn lại dùng Latin-1 và
      // làm hỏng tiếng Việt.
      return decode(jsonDecode(utf8.decode(response.bodyBytes)));
    } on ApiException {
      // Lỗi đã được phân loại ở trên, ném lại nguyên vẹn để không bọc hai lần.
      rethrow;
    } on http.ClientException {
      // Trên mobile/desktop, http bọc SocketException thành ClientException
      // nên không cần import thư viện IO và vẫn build được cho web.
      throw const ApiException.network();
    } on TimeoutException {
      throw const ApiException.network();
    } on FormatException {
      // Body không phải JSON hợp lệ hoặc không phải UTF-8.
      throw const ApiException.parse();
    } on TypeError {
      // JSON đúng cú pháp nhưng sai cấu trúc: thiếu field hoặc sai kiểu.
      throw const ApiException.parse();
    }
  }
}
