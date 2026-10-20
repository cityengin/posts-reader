import 'package:mocktail/mocktail.dart';
import 'package:posts_reader/features/posts/domain/repositories/post_repository.dart';

// Mock dùng chung cho các test UseCase. Vì UseCase chỉ phụ thuộc vào
// abstraction nên có thể thay repository thật bằng mock mà không cần mạng.
class MockPostRepository extends Mock implements PostRepository {}
