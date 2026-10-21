import 'package:flutter/material.dart';
import 'package:posts_reader/services/post_service.dart';
import 'package:posts_reader/viewmodels/post_detail_view_model.dart';
import 'package:posts_reader/viewmodels/post_list_view_model.dart';
import 'package:posts_reader/views/post_list_view.dart';

// main.dart là composition root - nơi duy nhất biết PostService.
// View chỉ nhận ViewModel qua hàm tạo (factory), giữ cho các tầng độc lập.
void main() {
  final service = PostService();

  runApp(
    PostsReaderApp(
      createListViewModel: () => PostListViewModel(service),
      createDetailViewModel: (id) => PostDetailViewModel(service, id),
    ),
  );
}

/// Root widget của ứng dụng Posts Reader.
class PostsReaderApp extends StatelessWidget {
  const PostsReaderApp({
    super.key,
    required this.createListViewModel,
    required this.createDetailViewModel,
  });

  final PostListViewModel Function() createListViewModel;
  final PostDetailViewModel Function(int postId) createDetailViewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: PostListView(
        createViewModel: createListViewModel,
        createDetailViewModel: createDetailViewModel,
      ),
    );
  }
}
