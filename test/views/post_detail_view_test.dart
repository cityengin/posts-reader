import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posts_reader/models/post.dart';
import 'package:posts_reader/services/api_exception.dart';
import 'package:posts_reader/viewmodels/post_detail_view_model.dart';
import 'package:posts_reader/views/post_detail_view.dart';

import 'fake_post_service.dart';

void main() {
  late FakePostService service;

  const samplePost = Post(
    id: 42,
    userId: 1,
    title: 'Tiêu đề bài viết số 42',
    body: 'Nội dung chi tiết bài viết số 42...',
  );

  setUp(() {
    service = FakePostService();
  });

  Widget createWidgetUnderTest(int postId) {
    return MaterialApp(
      home: PostDetailView(
        createViewModel: () => PostDetailViewModel(service, postId),
      ),
    );
  }

  testWidgets(
    'PostDetailView: service ném ApiException.notFound() thì hiện message "Không tìm thấy bài viết." và KHÔNG tìm thấy nút "Thử lại"',
    (tester) async {
      service.onFetchPostById = (_) async =>
          throw const ApiException.notFound();

      await tester.pumpWidget(createWidgetUnderTest(999));
      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy bài viết.'), findsOneWidget);
      expect(find.text('Thử lại'), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
    },
  );

  testWidgets(
    'PostDetailView: hiển thị tiêu đề và nội dung khi tải thành công',
    (tester) async {
      service.onFetchPostById = (_) async => samplePost;

      await tester.pumpWidget(createWidgetUnderTest(42));
      await tester.pumpAndSettle();

      expect(find.text('Chi tiết bài viết'), findsOneWidget);
      expect(find.text('Tiêu đề bài viết số 42'), findsOneWidget);
      expect(find.text('Nội dung chi tiết bài viết số 42...'), findsOneWidget);
    },
  );
}
