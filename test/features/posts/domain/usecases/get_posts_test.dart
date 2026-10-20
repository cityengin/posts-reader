import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_reader/core/error/failure.dart';
import 'package:posts_reader/features/posts/domain/entities/post.dart';
import 'package:posts_reader/features/posts/domain/usecases/get_posts.dart';

import '../../../../helpers/mock_post_repository.dart';

void main() {
  late MockPostRepository repository;
  late GetPosts getPosts;

  setUp(() {
    repository = MockPostRepository();
    getPosts = GetPosts(repository);
  });

  const posts = [
    Post(id: 1, userId: 1, title: 'Tiêu đề 1', body: 'Nội dung 1'),
    Post(id: 2, userId: 1, title: 'Tiêu đề 2', body: 'Nội dung 2'),
  ];

  group('GetPosts', () {
    test('trả về danh sách bài viết khi repository thành công', () async {
      when(() => repository.getPosts()).thenAnswer((_) async => posts);

      final result = await getPosts();

      expect(result, posts);
      verify(() => repository.getPosts()).called(1);
      verifyNoMoreInteractions(repository);
    });

    // Lỗi được ném bên trong Future (thenAnswer + async) thay vì thenThrow,
    // giống repository thật khi request HTTP thất bại.
    test('ném NetworkFailure khi repository ném NetworkFailure', () async {
      when(() => repository.getPosts())
          .thenAnswer((_) async => throw const NetworkFailure());

      await expectLater(getPosts(), throwsA(isA<NetworkFailure>()));

      verify(() => repository.getPosts()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('ném ServerFailure giữ nguyên statusCode từ repository', () async {
      when(() => repository.getPosts())
          .thenAnswer((_) async => throw const ServerFailure(500));

      await expectLater(
        getPosts(),
        throwsA(
          isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 500),
        ),
      );

      verify(() => repository.getPosts()).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
