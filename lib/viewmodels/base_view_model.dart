import 'package:flutter/foundation.dart';
import 'package:posts_reader/services/api_exception.dart';

/// Trạng thái của một lần tải dữ liệu.
enum LoadStatus { loading, success, error }

/// Lớp cha cho các ViewModel có thao tác tải dữ liệu.
///
/// Luồng dữ liệu một chiều:
/// 1. View gọi hàm của ViewModel (ví dụ `load()`).
/// 2. ViewModel đổi state rồi gọi [notifyListeners].
/// 3. View lắng nghe, đọc state qua getter và vẽ lại.
///
/// View không tự đổi state: mọi field đều private, chỉ lộ getter.
///
/// Chỉ dựa vào foundation (ChangeNotifier), không phụ thuộc widget, nên test
/// được mà không cần dựng giao diện.
abstract class BaseViewModel extends ChangeNotifier {
  // Mặc định là loading vì View sẽ gọi load() ngay khi mở màn hình; tránh
  // hiện thoáng qua trạng thái "rỗng" trước khi bắt đầu tải.
  LoadStatus _status = LoadStatus.loading;
  String? _errorMessage;
  bool _canRetry = false;
  bool _disposed = false;

  LoadStatus get status => _status;

  /// Thông điệp lỗi tiếng Việt, chỉ khác null khi [status] là
  /// [LoadStatus.error].
  String? get errorMessage => _errorMessage;

  /// View dựa vào đây để quyết định có hiện nút "Thử lại" hay không.
  bool get canRetry => _canRetry;

  /// Chạy [action] và cập nhật [status], [errorMessage], [canRetry] theo kết
  /// quả.
  ///
  /// Không để exception thoát ra ngoài: lỗi được chuyển thành state để View
  /// hiển thị, View không cần try-catch.
  @protected
  Future<void> runLoad(Future<void> Function() action) async {
    _status = LoadStatus.loading;
    _errorMessage = null;
    _canRetry = false;
    notifyListeners();

    try {
      await action();
      _status = LoadStatus.success;
    } on ApiException catch (e) {
      _status = LoadStatus.error;
      _errorMessage = e.message;
      _canRetry = e.isRetryable;
    } catch (_) {
      _status = LoadStatus.error;
      _errorMessage = 'Đã xảy ra lỗi không xác định.';
      _canRetry = true;
    }

    notifyListeners();
  }

  // Người dùng có thể thoát màn hình (ViewModel bị dispose) khi request vẫn
  // đang chạy. Bỏ qua thông báo sau dispose để tránh lỗi gọi ChangeNotifier
  // đã bị hủy.
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
