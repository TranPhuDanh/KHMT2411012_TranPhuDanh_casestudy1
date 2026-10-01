# Expense Manager - Ứng Dụng Quản Lý Thu Chi Cá Nhân

**Học phần:** Case Study 1 - Lập trình ứng dụng di động với Flutter  
**Sinh viên thực hiện:** Trần Phú Danh  
**Mã số sinh viên:** KHMT2411012  
**Khoa/Trường:** Đại học Kỹ thuật - Công nghệ Cần Thơ (CTUET)  
**Repository:** [TranPhuDanh/KHMT2411012_TranPhuDanh_casestudy1](https://github.com/TranPhuDanh/KHMT2411012_TranPhuDanh_casestudy1)

---

## 📌 Tiến độ thực hiện theo từng buổi

| Buổi | Tên nhánh Git | Nội dung hoàn thành |
| :---: | :--- | :--- |
| **Buổi 1** | `buoi1` | Khởi tạo dự án Flutter ban đầu, cấu hình môi trường phát triển. |
| **Buổi 2** | `buoi2` | Xây dựng giao diện **Màn hình Chào mừng (WelcomeScreen / Onboarding)** với icon ví tiền vẽ tùy biến, giới thiệu ứng dụng và nút Bắt đầu. |
| **Buổi 3** | `buoi3` | Xây dựng giao diện **Màn hình Thêm giao dịch (`AddTransactionScreen`)** và **Màn hình Sửa giao dịch (`EditTransactionScreen`)**. |
| **Buổi 4** | `buoi4` | Xây dựng **Màn hình Dashboard Quản lý thu chi (`DashboardScreen`)** và liên kết điều hướng hoàn chỉnh giữa các màn hình. |
| **Buổi 5** | `buoi5` | **Thiết kế và xây dựng cơ sở dữ liệu SQLite cho ứng dụng**: Mô hình hóa CSDL quan hệ (`categories`, `transactions`), xây dựng Singleton `DatabaseHelper`, thực hiện trọn vẹn CRUD, tính toán thống kê tự động và đồng bộ trực tiếp với giao diện. |

---

## 💾 Kiến trúc Cơ sở dữ liệu SQLite (Buổi 5)

Chi tiết thiết kế, sơ đồ ERD và các câu lệnh SQL được tài liệu hóa đầy đủ tại:  
👉 **[TÀI LIỆU THIẾT KẾ CƠ SỞ DỮ LIỆU SQLITE (DATABASE_DESIGN.md)](DATABASE_DESIGN.md)**

### Cấu trúc các bảng:
- **`categories`**: Quản lý danh mục thu / chi (Ăn uống, Di chuyển, Mua sắm, Giải trí, Giáo dục, Lương, Thưởng,...).
- **`transactions`**: Quản lý các giao dịch thu chi cá nhân (Tiêu đề, Số tiền, Danh mục, Khóa ngoại `category_id`, Ngày, Loại thu/chi, Ghi chú).

---

## 🛠️ Công nghệ & Thư viện sử dụng
- **Flutter SDK**: 3.47+ / **Dart SDK**: 3.13+
- **sqflite**: Hệ quản trị cơ sở dữ liệu SQLite cho ứng dụng di động.
- **path**: Quản lý đường dẫn tập tin CSDL cross-platform.
- **sqflite_common_ffi**: Hỗ trợ thực thi SQLite trên môi trường Desktop và Unit Test.

---

## 🧪 Kiểm thử (Testing)
Dự án được viết unit test đầy đủ cho SQLite và Widget:
```bash
# Chạy toàn bộ các bài test
flutter test

# Kiểm tra phân tích cú pháp tĩnh
flutter analyze
```
- Kết quả: **`All tests passed!` (8/8 tests pass, 0 issues)**.
