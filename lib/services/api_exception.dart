/// Loại lỗi khi gọi API, để tầng trên xử lý theo loại thay vì so sánh message.
enum ApiErrorType { network, server, notFound, parse }

/// Lỗi duy nhất mà `PostService` ném ra ngoài.
///
/// Mỗi loại lỗi có một named constructor riêng để message tiếng Việt luôn
/// thống nhất và [statusCode] chỉ có giá trị ở lỗi server.
class ApiException implements Exception {
  const ApiException._(this.type, this.message, [this.statusCode]);

  const ApiException.network()
    : this._(
        ApiErrorType.network,
        'Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng.',
      );

  const ApiException.server(int statusCode)
    : this._(
        ApiErrorType.server,
        'Máy chủ trả về lỗi (mã $statusCode).',
        statusCode,
      );

  const ApiException.notFound()
    : this._(ApiErrorType.notFound, 'Không tìm thấy bài viết.');

  const ApiException.parse()
    : this._(ApiErrorType.parse, 'Dữ liệu từ máy chủ không hợp lệ.');

  final ApiErrorType type;

  /// Thông điệp tiếng Việt, hiển thị được ngay cho người dùng.
  final String message;

  /// Mã HTTP, chỉ khác null khi [type] là [ApiErrorType.server].
  final int? statusCode;

  /// Bài viết không tồn tại thì thử lại cũng vô ích; các lỗi còn lại có thể
  /// chỉ là tạm thời.
  bool get isRetryable => type != ApiErrorType.notFound;

  @override
  String toString() => 'ApiException(${type.name}): $message';
}
