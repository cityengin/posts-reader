import 'package:flutter/material.dart';
import 'package:posts_reader/models/post.dart';
import 'package:posts_reader/viewmodels/base_view_model.dart';
import 'package:posts_reader/viewmodels/post_detail_view_model.dart';
import 'package:posts_reader/viewmodels/post_list_view_model.dart';
import 'package:posts_reader/views/post_detail_view.dart';
import 'package:posts_reader/views/widgets/error_retry_view.dart';

/// Màn hình danh sách bài viết.
class PostListView extends StatefulWidget {
  const PostListView({
    super.key,
    required this.createViewModel,
    required this.createDetailViewModel,
  });

  final PostListViewModel Function() createViewModel;
  final PostDetailViewModel Function(int postId) createDetailViewModel;

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  // Nguyên tắc "ai tạo thì người đó dispose": State tạo ViewModel và tự hủy khi rời màn hình.
  late final PostListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.createViewModel();
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài viết')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return switch (_viewModel.status) {
            LoadStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            LoadStatus.error => ErrorRetryView(
              message: _viewModel.errorMessage ?? '',
              onRetry: _viewModel.canRetry ? _viewModel.load : null,
            ),
            LoadStatus.success => _buildList(context, _viewModel.posts),
          };
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Post> posts) {
    return ListView.separated(
      itemCount: posts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final post = posts[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${post.id}')),
          title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            post.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PostDetailView(
                  createViewModel: () => widget.createDetailViewModel(post.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
