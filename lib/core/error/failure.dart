/// Lỗi nghiệp vụ dùng chung cho toàn app.
///
/// Implement [Exception] để báo lỗi bằng `throw`/`try-catch` thuần Dart,
/// không cần kiểu `Either` của dartz.
///
/// Khai báo `sealed` để tầng Presentation có thể `switch` vét cạn mọi loại
/// lỗi: thêm một Failure mới mà quên xử lý thì trình biên dịch sẽ báo.
sealed class Failure implements Exception {
  const Failure(this.message);

  /// Mô tả ngắn gọn về lỗi, phục vụ log và hiển thị.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Không kết nối được tới máy chủ (mất mạng, timeout, lỗi DNS...).
class NetworkFailure extends Failure {
  const NetworkFailure() : super('Không thể kết nối tới máy chủ.');
}

/// Máy chủ phản hồi với mã HTTP lỗi.
class ServerFailure extends Failure {
  const ServerFailure(this.statusCode)
    : super('Máy chủ trả về lỗi (mã $statusCode).');

  /// Mã trạng thái HTTP mà máy chủ trả về.
  final int statusCode;
}

/// Không tìm thấy dữ liệu được yêu cầu, ví dụ bài viết có id không tồn tại.
///
/// Tách riêng khỏi [ServerFailure] vì UI xử lý khác: báo "không tồn tại"
/// thay vì gợi ý người dùng thử lại.
class NotFoundFailure extends Failure {
  const NotFoundFailure() : super('Không tìm thấy dữ liệu yêu cầu.');
}
