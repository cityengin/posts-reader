import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posts_reader/models/post.dart';
import 'package:posts_reader/services/api_exception.dart';
import 'package:posts_reader/viewmodels/post_detail_view_model.dart';
import 'package:posts_reader/viewmodels/post_list_view_model.dart';
import 'package:posts_reader/views/post_list_view.dart';

import 'fake_post_service.dart';

void main() {
  late FakePostService service;

  const samplePosts = [
    Post(id: 1, userId: 1, title: 'Tiêu đề 1', body: 'Nội dung 1'),
    Post(id: 2, userId: 1, title: 'Tiêu đề 2', body: 'Nội dung 2'),
  ];

  setUp(() {
    service = FakePostService();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: PostListView(
        createViewModel: () => PostListViewModel(service),
        createDetailViewModel: (id) => PostDetailViewModel(service, id),
      ),
    );
  }

  testWidgets(
    'PostListView: lúc chờ hiện CircularProgressIndicator, hoàn tất thì hiện danh sách các title',
    (tester) async {
      final completer = Completer<List<Post>>();
      service.onFetchPosts = () => completer.future;

      await tester.pumpWidget(createWidgetUnderTest());

      // Trong lúc chờ tải dữ liệu, CircularProgressIndicator chạy animation liên tục
      // nên chỉ pump() từng frame, không dùng pumpAndSettle() để tránh timeout.
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Tiêu đề 1'), findsNothing);

      completer.complete(samplePosts);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Tiêu đề 1'), findsOneWidget);
      expect(find.text('Tiêu đề 2'), findsOneWidget);
    },
  );

  testWidgets(
    'PostListView: service ném ApiException.network() thì hiện message + nút "Thử lại"; bấm "Thử lại" thì hiện danh sách',
    (tester) async {
      service.onFetchPosts = () async => throw const ApiException.network();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.text('Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng.'),
        findsOneWidget,
      );
      final retryButton = find.text('Thử lại');
      expect(retryButton, findsOneWidget);

      // Lần gọi tiếp theo thành công
      service.onFetchPosts = () async => samplePosts;

      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(find.text('Tiêu đề 1'), findsOneWidget);
      expect(find.text('Tiêu đề 2'), findsOneWidget);
      expect(
        find.text('Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng.'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'PostListView: bấm một dòng thì mở màn chi tiết và hiện body của bài viết đó',
    (tester) async {
      service.onFetchPosts = () async => samplePosts;
      service.onFetchPostById = (id) async =>
          samplePosts.firstWhere((p) => p.id == id);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Bấm vào bài viết thứ nhất
      await tester.tap(find.text('Tiêu đề 1'));
      await tester.pumpAndSettle();

      expect(find.text('Chi tiết bài viết'), findsOneWidget);
      expect(find.text('Nội dung 1'), findsOneWidget);
    },
  );
}
