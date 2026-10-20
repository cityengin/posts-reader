import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:posts_reader/models/post.dart';
import 'package:posts_reader/services/api_exception.dart';
import 'package:posts_reader/services/post_service.dart';

const _baseUrl = 'https://jsonplaceholder.typicode.com';

// Trả về JSON dạng bytes UTF-8 và không khai báo Content-Type, để kiểm tra
// service tự giải mã UTF-8 đúng (tiêu đề có dấu tiếng Việt).
http.Response _jsonResponse(Object? json, [int statusCode = 200]) =>
    http.Response.bytes(utf8.encode(jsonEncode(json)), statusCode);

Matcher _throwsApiException(ApiErrorType type) =>
    throwsA(isA<ApiException>().having((e) => e.type, 'type', type));

void main() {
  const firstPost = Post(
    id: 1,
    userId: 1,
    title: 'Tiêu đề có dấu',
    body: 'Nội dung 1',
  );
  const secondPost = Post(id: 2, userId: 1, title: 'Title 2', body: 'Body 2');

  Map<String, dynamic> toJson(Post post) => {
    'id': post.id,
    'userId': post.userId,
    'title': post.title,
    'body': post.body,
  };

  group('PostService.fetchPosts', () {
    test('GET /posts và parse đúng danh sách Post', () async {
      late http.Request sentRequest;
      final service = PostService(
        client: MockClient((request) async {
          sentRequest = request;
          return _jsonResponse([toJson(firstPost), toJson(secondPost)]);
        }),
      );

      final posts = await service.fetchPosts();

      expect(posts, [firstPost, secondPost]);
      expect(sentRequest.method, 'GET');
      expect(sentRequest.url, Uri.parse('$_baseUrl/posts'));
    });

    test('status 500 → ApiException server kèm statusCode 500', () async {
      final service = PostService(
        client: MockClient((_) async => http.Response('', 500)),
      );

      await expectLater(
        service.fetchPosts(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.type, 'type', ApiErrorType.server)
              .having((e) => e.statusCode, 'statusCode', 500)
              .having(
                (e) => e.message,
                'message',
                'Máy chủ trả về lỗi (mã 500).',
              ),
        ),
      );
    });

    test('client ném ClientException → ApiException network', () async {
      final service = PostService(
        client: MockClient(
          (_) async => throw http.ClientException('Mất kết nối'),
        ),
      );

      await expectLater(
        service.fetchPosts(),
        _throwsApiException(ApiErrorType.network),
      );
    });

    test('body không phải JSON hợp lệ → ApiException parse', () async {
      final service = PostService(
        client: MockClient(
          (_) async => http.Response('<html>oops</html>', 200),
        ),
      );

      await expectLater(
        service.fetchPosts(),
        _throwsApiException(ApiErrorType.parse),
      );
    });
  });

  group('PostService.fetchPostById', () {
    test('GET /posts/{id} và parse đúng một Post', () async {
      late http.Request sentRequest;
      final service = PostService(
        client: MockClient((request) async {
          sentRequest = request;
          return _jsonResponse(toJson(firstPost));
        }),
      );

      final post = await service.fetchPostById(1);

      expect(post, firstPost);
      expect(sentRequest.method, 'GET');
      expect(sentRequest.url, Uri.parse('$_baseUrl/posts/1'));
    });

    test('status 404 → ApiException notFound', () async {
      final service = PostService(
        client: MockClient((_) async => http.Response('{}', 404)),
      );

      await expectLater(
        service.fetchPostById(9999),
        _throwsApiException(ApiErrorType.notFound),
      );
    });

    test('JSON thiếu field → ApiException parse', () async {
      final service = PostService(
        client: MockClient(
          (_) async =>
              _jsonResponse({'id': 1, 'userId': 1, 'title': 'Thiếu body'}),
        ),
      );

      await expectLater(
        service.fetchPostById(1),
        _throwsApiException(ApiErrorType.parse),
      );
    });
  });
}
