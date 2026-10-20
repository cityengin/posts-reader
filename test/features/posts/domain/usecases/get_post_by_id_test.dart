import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posts_reader/core/error/failure.dart';
import 'package:posts_reader/features/posts/domain/entities/post.dart';
import 'package:posts_reader/features/posts/domain/usecases/get_post_by_id.dart';

import '../../../../helpers/mock_post_repository.dart';

void main() {
  late MockPostRepository repository;
  late GetPostById getPostById;

  setUp(() {
    repository = MockPostRepository();
    getPostById = GetPostById(repository);
  });

  const postId = 1;
  const post = Post(
    id: postId,
    userId: 1,
    title: 'Tiêu đề 1',
    body: 'Nội dung 1',
  );

  group('GetPostById', () {
    test('trả về bài viết đúng id khi repository thành công', () async {
      when(() => repository.getPostById(postId)).thenAnswer((_) async => post);

      final result = await getPostById(postId);

      expect(result, post);
      // verifyNoMoreInteractions đảm bảo không có lời gọi nào với id khác.
      verify(() => repository.getPostById(postId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('ném NotFoundFailure khi bài viết không tồn tại', () async {
      const missingId = 9999;
      when(() => repository.getPostById(missingId))
          .thenAnswer((_) async => throw const NotFoundFailure());

      await expectLater(
        getPostById(missingId),
        throwsA(isA<NotFoundFailure>()),
      );

      verify(() => repository.getPostById(missingId)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('ném NetworkFailure khi repository ném NetworkFailure', () async {
      when(() => repository.getPostById(postId))
          .thenAnswer((_) async => throw const NetworkFailure());

      await expectLater(getPostById(postId), throwsA(isA<NetworkFailure>()));

      verify(() => repository.getPostById(postId)).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
