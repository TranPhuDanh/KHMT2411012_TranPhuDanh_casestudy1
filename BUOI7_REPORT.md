# BÁO CÁO KẾT QUẢ THỰC HIỆN BUỔI 7
## HOÀN THIỆN MÀN HÌNH THỐNG KÊ, MÀN HÌNH CÁ NHÂN VÀ MÀN HÌNH BỘ LỌC

- **Sinh viên thực hiện:** Trần Phú Danh
- **Mã số sinh viên:** KHMT2411012
- **Học phần:** Case Study 1 - Lập trình ứng dụng di động với Flutter
- **Khoa/Trường:** Đại học Kỹ thuật - Công nghệ Cần Thơ (CTUET)
- **Nhánh Git:** `buoi7`
- **GitHub Repository:** [TranPhuDanh/KHMT2411012_TranPhuDanh_casestudy1](https://github.com/TranPhuDanh/KHMT2411012_TranPhuDanh_casestudy1/tree/buoi7)

---

## 1. Yêu cầu & Mục tiêu buổi 7
Trong buổi 7, ứng dụng cần hoàn thiện 3 màn hình nghiệp vụ trọng tâm theo đúng thiết kế mockup:
1. **Màn hình Thống kê (`StatisticsView` / `StatisticsScreen`):**
   - Bộ lọc kỳ hạn 3 nút: **Tháng này**, **Tháng trước**, **Năm nay**.
   - Biểu đồ vành khuyên (**Donut Chart**) vẽ tùy biến bằng `CustomPainter` hiển thị tổng chi tiêu ở tâm và các lát cắt màu sắc đại diện cho các nhóm danh mục.
   - Bảng phân rã chi tiết danh mục gồm: chấm màu, tên danh mục, số tiền định dạng VNĐ và tỷ lệ phần trăm (Ăn uống 40%, Mua sắm 30%, Đi lại 14%, Học tập 10%, Khác 6%).
2. **Màn hình Cá nhân (`ProfileView` / `ProfileScreen`):**
   - Header đại diện người dùng với ảnh đại diện CircleAvatar (nền xanh pastel, icon người màu trắng), họ tên ("Nguyễn Văn A") và email ("nguyenvana@example.com").
   - Danh sách 6 tùy chọn thiết lập hệ thống:
     1. Thông tin cá nhân (chỉnh sửa họ tên, email)
     2. Cài đặt ngân sách (thiết lập hạn mức chi tiêu tháng)
     3. Danh mục chi tiêu (xem danh mục từ SQLite)
     4. Sao lưu dữ liệu (đồng bộ và sao lưu an toàn CSDL SQLite)
     5. Đổi mật khẩu (hộp thoại bảo mật)
     6. Đăng xuất (màu đỏ cảnh báo với hộp thoại xác nhận)
3. **Màn hình Bộ lọc (`FilterScreen`):**
   - Nút quay lại AppBar và tiêu đề "Bộ lọc".
   - **Loại giao dịch:** Hộp chọn Checkbox cho *Tất cả*, *Thu nhập*, *Chi tiêu*.
   - **Danh mục:** DropdownButton bo góc tùy chọn danh mục cụ thể hoặc *Tất cả danh mục*.
   - **Khoảng thời gian:** Radio tùy chọn *Hôm nay*, *7 ngày qua*, *Tháng này*, *Tùy chỉnh* (mở DateRangePicker chọn từ ngày đến ngày).
   - Nút lớn **Áp dụng** toàn chiều rộng màn hình gửi tiêu chí lọc ngược về danh sách giao dịch SQLite.

---

## 2. Cấu trúc mã nguồn triển khai

```
lib/
├── database/
│   └── database_helper.dart      # Singleton quản lý CSDL SQLite
├── models/
│   ├── category_model.dart       # Model danh mục
│   ├── transaction_model.dart    # Model giao dịch
│   ├── filter_criteria.dart      # Model lưu trữ tiêu chí lọc
│   ├── user_model.dart           # Model người dùng & tài khoản
│   └── budget_model.dart         # [MỚI] Model quản lý nhiều hạn mức ngân sách
├── screens/
│   ├── filter_screen.dart        # Màn hình Bộ lọc giao dịch
│   ├── login_screen.dart         # Màn hình Đăng nhập & Tạo tài khoản
│   ├── profile_screen.dart       # Màn hình Cá nhân
│   ├── statistics_screen.dart    # Màn hình Thống kê & DonutChart
│   └── budget_screen.dart        # [MỚI] Màn hình Quản lý Nhiều Hạn mức Ngân sách
└── main.dart                     # Ứng dụng chính, Welcome & Dashboard
test/
├── database_test.dart            # Test CSDL SQLite CRUD, UserModel & BudgetModel (19 tests)
├── buoi7_screens_test.dart       # Test các màn hình, BudgetScreen & xác thực (13 tests)
└── widget_test.dart              # Test màn hình Welcome (1 test)
```

---

## 3. Chi tiết kỹ thuật các màn hình

### 3.1. Màn hình Thống kê (`StatisticsView`)
- **Donut Chart Painter:** Vẽ hình vành khuyên bằng `Canvas.drawArc` với `PaintingStyle.stroke`, `strokeWidth = 32`, bắt đầu từ góc 12 giờ (`-pi/2`).
- **Trung tâm biểu đồ:** Sử dụng `Stack` lồng dữ liệu tổng chi tiêu (`5.000.000 đ`) và nhãn phụ `Tổng chi tiêu`.
- **Tương tác linh hoạt:** Chuyển đổi mượt mà giữa các kỳ `Tháng này` (5.000.000 đ), `Tháng trước` (4.200.000 đ) và `Năm nay` (18.500.000 đ).

### 3.2. Màn hình Cá nhân (`ProfileView`)
- **Thẻ Avatar:** Đường kính 68px, màu nền `Color(0xFF93C5FD)`, icon người màu trắng 42px.
- **Tương tác chức năng:**
  - Hiển thị tên và email người dùng đã đăng nhập.
  - Chỉnh sửa thông tin cá nhân và cập nhật State ngay lập tức.
  - Điều chỉnh hạn mức ngân sách chi tiêu hàng tháng.
  - Xem toàn bộ danh mục động từ bảng `categories` SQLite qua `showModalBottomSheet`.
  - Hộp thoại Đăng xuất an toàn với nút xác nhận hủy hoặc đăng xuất đưa về màn hình Đăng nhập / Bắt đầu.

### 3.3. Màn hình Bộ lọc (`FilterScreen`)
- **Model `FilterCriteria`:** Đóng gói trạng thái lọc kiểu immutable, hỗ trợ `copyWith`.
- **Đồng bộ với Dashboard:** Tích hợp nút mở bộ lọc nhanh (icon `tune_rounded`) trên Tab Giao dịch; hiển thị thanh trạng thái đang lọc kèm nút hủy lọc tiện lợi.

### 3.4. Tối ưu hóa Màn hình Thêm & Sửa giao dịch (`AddTransactionScreen` / `EditTransactionScreen`)
- Tách biệt rõ ràng 3 ô nhập liệu độc lập: **Tên giao dịch**, **Tiêu đề**, và **Ghi chú**.
- Thiết kế TextField với `OutlineInputBorder`, hiển thị viền xanh `#2563EB` khi active (focus) giúp phản hồi cảm ứng và thao tác gõ phím trên thiết bị / máy ảo mượt mà, chuẩn xác.
- Đồng bộ trường `transaction_name` xuống CSDL SQLite, đảm bảo hiển thị chi tiết tên, tiêu đề và ghi chú lên danh sách giao dịch Dashboard.

### 3.5. Màn hình Đăng nhập & Tạo tài khoản (`LoginScreen`)
- **Điều hướng tự động:** Chuyển tiếp liền mạch từ nút "Bắt đầu" ở màn hình chào mừng (`WelcomeScreen`) sang màn hình Đăng nhập / Tạo tài khoản.
- **Thanh chuyển Tab (Segmented Switch):** Chuyển đổi linh hoạt giữa form **Đăng nhập** và **Tạo tài khoản** ngay trên giao diện mà không cần reload trang.
- **Tính năng Đăng nhập:**
  - Nhập Email / Tên đăng nhập và Mật khẩu (có icon mắt ẩn/hiện mật khẩu).
  - Checkbox ghi nhớ đăng nhập và hộp thoại "Quên mật khẩu?".
  - Banner tài khoản mẫu (`nguyenvana@example.com / 123`) kèm nút "Điền" một chạm tiện lợi.
  - Nút "Bỏ qua, vào thẳng ứng dụng" cho phép trải nghiệm nhanh dưới tư cách khách.
- **Tính năng Tạo tài khoản:**
  - Đăng ký đầy đủ: Họ và tên, Email, Mật khẩu, Xác nhận mật khẩu.
  - Kiểm tra tính hợp lệ dữ liệu và lưu trữ an toàn vào bảng `users` trong CSDL SQLite.
  - Tự động đăng nhập và đồng bộ họ tên, email lên trang Cá nhân (`ProfileView`).

### 3.6. Xử lý lỗi tràn viền (RenderFlex Overflow sọc vàng đen/đỏ)
- **Nguyên nhân dải sọc dọc:** Trên danh sách giao dịch gần đây, khi tiêu đề giao dịch (`item.title`) hoặc tên giao dịch dài, tổng kích thước văn bản vượt quá khoảng trống ngang còn lại của `Row` trước cột số tiền, dẫn đến cơ chế gỡ lỗi của Flutter kích hoạt banner sọc cảnh báo `RenderFlex overflowed by ... pixels on the right`.
- **Giải pháp xử lý:**
  - Áp dụng `overflow: TextOverflow.ellipsis` và `maxLines: 1` cho Tên giao dịch.
  - Bọc cụm tiêu đề phụ `• ${item.title}` trong widget `Flexible(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis))` để tự động thu gọn bằng dấu ba chấm `...` khi kích thước vượt hạn mức.
  - Đảm bảo giao diện luôn hiển thị ngay ngắn, mượt mà trên mọi kích thước màn hình mà không bao giờ bị đè cột số tiền hay hiện vệt sọc lỗi.

### 3.7. Màn hình Quản lý Nhiều Hạn mức Ngân sách (`BudgetScreen`)
- **Đáp ứng nhu cầu:** Cho phép người dùng thiết lập không giới hạn số lượng hạn mức ngân sách khác nhau (theo từng danh mục cụ thể như Ăn uống, Mua sắm, Di chuyển... hoặc tổng chi tiêu toàn tháng, toàn tuần).
- **Tính năng chi tiết:**
  - **Model `BudgetModel` & Bảng `budgets`:** Lưu trữ `id`, `name`, `category`, `limit_amount`, `period` trực tiếp trong SQLite.
  - **Theo dõi tiến độ thời gian thực:** Tự động tính toán số tiền đã chi tiêu thực tế từ bảng giao dịch `transactions` cho từng danh mục (`DatabaseHelper.instance.getSpentForBudget`).
  - **Thanh tiến độ trực quan đa trạng thái màu:**
    - Xanh lá (`#10B981`): Chi tiêu an toàn (< 80%).
    - Vàng cam (`#F59E0B`): Cảnh báo gần chạm mức (80% - 100%).
    - Đỏ (`#EF4444`): Cảnh báo vượt hạn mức (> 100%).
  - **Thêm hạn mức khác:** Nút bấm `+ Thêm hạn mức khác` mở hộp thoại nhập Tên hạn mức, chọn Danh mục áp dụng qua Dropdown, nhập Số tiền (VNĐ) và chọn Kỳ hạn (`Hàng tháng`, `Hàng tuần`, `Tháng này`).
  - **Sửa & Xóa hạn mức:** Hỗ trợ chỉnh sửa hoặc xóa nhanh từng hạn mức độc lập.

---

## 4. Kết quả Kiểm thử & Phân tích chất lượng mã nguồn

1. **Phân tích tĩnh (`flutter analyze`):**
   ```text
   Analyzing test1111...
   No issues found! (ran in 1.4s)
   ```
   - Đạt tiêu chuẩn sạch tuyệt đối: **0 lỗi, 0 cảnh báo, 0 lint issue**.

2. **Kiểm thử tự động (`flutter test`):**
   ```text
   00:03 +33: All tests passed!
   ```
   - Toàn bộ **33/33 test cases** chạy thành công rực rỡ (tăng từ 26 lên 33 test cases), bao gồm kiểm thử Đăng nhập, Tạo tài khoản, Thống kê, Cá nhân, Bộ lọc, Thêm giao dịch, Quản lý nhiều hạn mức ngân sách (`BudgetScreen`), CSDL SQLite CRUD (`BudgetModel`) và luồng nghiệp vụ.
