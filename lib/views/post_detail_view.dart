import 'package:flutter/material.dart';
import 'package:posts_reader/viewmodels/base_view_model.dart';
import 'package:posts_reader/viewmodels/post_detail_view_model.dart';
import 'package:posts_reader/views/widgets/error_retry_view.dart';

/// Màn hình hiển thị chi tiết một bài viết.
class PostDetailView extends StatefulWidget {
  const PostDetailView({
    super.key,
    required this.createViewModel,
  });

  final PostDetailViewModel Function() createViewModel;

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  // Nguyên tắc "ai tạo thì người đó dispose": State tạo ViewModel và tự hủy khi rời màn hình.
  late final PostDetailViewModel _viewModel;

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
      appBar: AppBar(
        title: const Text('Chi tiết bài viết'),
      ),
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
            LoadStatus.success => _buildContent(context),
          };
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final post = _viewModel.post;
    if (post == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16.0),
          Text(
            post.body,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
