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
│   └── filter_criteria.dart      # [MỚI] Model lưu trữ tiêu chí lọc
├── screens/
│   ├── filter_screen.dart        # [MỚI] Màn hình Bộ lọc giao dịch
│   ├── profile_screen.dart       # [MỚI] Màn hình Cá nhân
│   └── statistics_screen.dart    # [MỚI] Màn hình Thống kê & DonutChart
└── main.dart                     # Ứng dụng chính & Dashboard 4 tab
test/
├── database_test.dart            # Test CSDL SQLite CRUD (12 tests)
├── buoi7_screens_test.dart       # [MỚI] Test 3 màn hình Buổi 7 (6 tests)
└── widget_test.dart              # Test màn hình Welcome
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
  - Chỉnh sửa thông tin cá nhân và cập nhật State ngay lập tức.
  - Điều chỉnh hạn mức ngân sách chi tiêu hàng tháng.
  - Xem toàn bộ danh mục động từ bảng `categories` SQLite qua `showModalBottomSheet`.
  - Hộp thoại Đăng xuất an toàn với nút xác nhận hủy hoặc đăng xuất đưa về `WelcomeScreen`.

### 3.3. Màn hình Bộ lọc (`FilterScreen`)
- **Model `FilterCriteria`:** Đóng gói trạng thái lọc kiểu immutable, hỗ trợ `copyWith`.
- **Đồng bộ với Dashboard:** Tích hợp nút mở bộ lọc nhanh (icon `tune_rounded`) trên Tab Giao dịch; hiển thị thanh trạng thái đang lọc kèm nút hủy lọc tiện lợi.

---

## 4. Kết quả Kiểm thử & Phân tích chất lượng mã nguồn

1. **Phân tích tĩnh (`flutter analyze`):**
   ```text
   Analyzing test1111...
   No issues found! (ran in 1.3s)
   ```
   - Đạt tiêu chuẩn sạch tuyệt đối: **0 lỗi, 0 cảnh báo, 0 lint issue**.

2. **Kiểm thử tự động (`flutter test`):**
   ```text
   00:01 +18: All tests passed!
   ```
   - Toàn bộ **18/18 test cases** chạy thành công, bao gồm test giao diện Thống kê, Cá nhân, Bộ lọc, CSDL SQLite CRUD và luồng nghiệp vụ.
