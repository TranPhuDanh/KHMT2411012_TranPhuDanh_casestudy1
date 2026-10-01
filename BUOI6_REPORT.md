# BÁO CÁO THỰC HIỆN BUỔI 6: HOÀN THIỆN CÁC MÀN HÌNH THÊM, SỬA VÀ LOAD THÔNG TIN GIAO DỊCH LÊN DASHBOARD

**Dự án:** Expense Manager (Ứng dụng Quản lý thu chi cá nhân)  
**Học phần:** Case Study 1 - Lập trình ứng dụng di động với Flutter  
**Sinh viên thực hiện:** Trần Phú Danh  
**Mã số sinh viên:** KHMT2411012  
**Mục tiêu Buổi 6:** Hoàn thiện các màn hình thêm, sửa và load thông tin giao dịch lên màn hình Dashboard  

---

## 1. MÀN HÌNH DASHBOARD (QUẢN LÝ THU CHI)

### 1.1. Load dữ liệu tự động từ SQLite
- Phương thức `_loadData()` gọi bất đối xứng (`async/await`) qua `DatabaseHelper.instance`:
  - `getCurrentBalance()`: Tính toán số dư khả dụng (`Thu nhập - Chi tiêu`).
  - `getTotalIncome()`: Tổng hợp tất cả các khoản thu nhập.
  - `getTotalExpense()`: Tổng hợp tất cả các khoản chi tiêu.
  - `getRecentTransactions(limit: 5)`: Truy vấn 5 giao dịch gần đây nhất đưa lên Dashboard.
  - `getAllTransactions()`: Lấy toàn bộ giao dịch phục vụ hiển thị tab danh sách và thống kê.
- Tự động gọi `_loadData()` trong `initState()`, sau khi thêm giao dịch thành công, sau khi sửa/xóa giao dịch, hoặc khi người dùng vuốt màn hình để làm mới (`RefreshIndicator`).

### 1.2. Thẻ số dư & Tóm tắt thu chi
- **Thẻ Số dư hiện tại:**
  - Gradient xanh dương bo góc 22px với hiệu ứng đổ bóng.
  - Nút con mắt cho phép bật/tắt hiển thị số dư (`5.000.000 đ` <-> `•••••••• đ`).
  - Minh họa ví tiền kèm tờ tiền xanh và các đồng xu vàng y hệt mẫu thiết kế.
  - Đèn chỉ báo chuyển trang (Dots Indicator: 1 chấm dài + 3 chấm tròn).
- **Hàng Tổng thu nhập & Tổng chi tiêu:**
  - **TỔNG THU NHẬP:** Nền xanh nhạt, icon mũi tên xanh chỉ xuống trong vòng tròn xanh, số tiền màu xanh lá (`+8.000.000 đ`).
  - **TỔNG CHI TIÊU:** Nền đỏ nhạt, icon mũi tên đỏ chỉ lên trong vòng tròn đỏ, số tiền màu đỏ (`-3.000.000 đ`).

### 1.3. Danh sách Giao dịch gần đây
- Hiển thị danh sách 5 giao dịch mới nhất từ SQLite:
  1. **Ăn trưa** (`Ăn uống` - `03/09/2024`): `-50.000 đ` (Icon `restaurant` nền cam)
  2. **Xăng xe** (`Di chuyển` - `03/09/2024`): `-100.000 đ` (Icon `directions_car` nền xanh dương)
  3. **Lương tháng 9** (`Thu nhập` - `01/09/2024`): `+8.000.000 đ` (Icon `attach_money` nền xanh lá)
  4. **Mua sắm** (`Mua sắm` - `31/08/2024`): `-300.000 đ` (Icon `shopping_cart` nền tím)
  5. **Học phí** (`Giáo dục` - `30/08/2024`): `-500.000 đ` (Icon `school` nền xanh ngọc)
- **Tương tác:**
  - Nhấp vào bất kỳ giao dịch nào để chuyển sang `EditTransactionScreen` với dữ liệu tương ứng.
  - Hỗ trợ vuốt sang trái (`Dismissible`) để xóa nhanh giao dịch có hộp thoại xác nhận.
- **Nút "Xem tất cả":** Chuyển ngay sang Tab "Giao dịch" để xem đầy đủ danh sách.

### 1.4. Tab Giao dịch & Tab Thống kê
- **Tab Giao dịch:**
  - Tích hợp thanh tìm kiếm theo tên hoặc danh mục giao dịch.
  - Các nút lọc nhanh (Filter Chips): Tất cả, Chi tiêu, Thu nhập.
- **Tab Thống kê:**
  - Phân loại tỷ lệ chi tiêu theo từng danh mục từ SQLite kèm phần trăm (%) và thanh tiến trình `LinearProgressIndicator` nhiều màu.

---

## 2. MÀN HÌNH THÊM GIAO DỊCH (`AddTransactionScreen`)

- **Nút bấm chuyển đổi Chi tiêu / Thu nhập (Toggle):**
  - Chi tiêu: Active màu đỏ `#EF5350`.
  - Thu nhập: Active màu xanh `#1565C0`.
- **Dropdown Danh mục thông minh:**
  - Tự động thay đổi danh sách danh mục tương ứng khi người dùng đổi loại giao dịch (Chi tiêu hiển thị: *Ăn uống, Di chuyển, Mua sắm, Giải trí, Giáo dục, Khác*; Thu nhập hiển thị: *Thu nhập, Lương, Thưởng, Đầu tư, Khác*).
- **Các trường nhập liệu:**
  - Tên giao dịch: Nhập tiêu đề tùy chỉnh (mặc định lấy tên danh mục nếu để trống).
  - Số tiền: Chỉ nhận số, tự động kiểm tra số tiền > 0.
  - Ngày giao dịch: DatePicker trực quan (`showDatePicker`), định dạng chuẩn `dd/MM/yyyy`.
  - Ghi chú: Nhập ghi chú chi tiết.
- **Xử lý lưu:**
  - Thêm mới vào SQLite thông qua `DatabaseHelper.instance.insert()`.
  - Hiển thị thông báo `SnackBar` thành công và `Navigator.pop(context, true)`.
  - Dashboard nhận kết quả `true` và tự động cập nhật lại toàn bộ số liệu.

---

## 3. MÀN HÌNH SỬA GIAO DỊCH (`EditTransactionScreen`)

- **Đổ dữ liệu (Data Binding):**
  - Nhận đối tượng `TransactionModel` từ Dashboard.
  - Tự động điền đúng trạng thái: Loại giao dịch, Danh mục, Tên, Số tiền, Ngày tháng, Ghi chú.
- **Chức năng Cập nhật (Update):**
  - Bấm nút "Lưu thay đổi": Kiểm tra hợp lệ và gọi `DatabaseHelper.instance.update()`.
  - Hiển thị thông báo SnackBar cập nhật thành công, đóng màn hình và cập nhật lại Dashboard.
- **Chức năng Xóa (Delete):**
  - Được bố trí tại 2 vị trí: Icon thùng rác đỏ trên AppBar và nút "Xóa giao dịch" viền đỏ ở cuối màn hình.
  - Hiển thị hộp thoại `AlertDialog` yêu cầu xác nhận để tránh người dùng bấm nhầm.
  - Khi xác nhận: Gọi `DatabaseHelper.instance.delete(id)`, xóa bản ghi trong SQLite và đồng bộ về Dashboard.

---

## 4. KẾT QUẢ KIỂM THỬ & CHẤT LƯỢNG MÃ NGUỒN

- **Unit Tests & Widget Tests (`flutter test`):**
  - `test/database_test.dart`: 11 test cases kiểm thử CategoryModel, TransactionModel, SQLite CRUD, tính toán số dư và load recent transactions.
  - `test/widget_test.dart`: 1 test case kiểm thử giao diện WelcomeScreen.
  - **Kết quả:** `All tests passed! (12/12 passed)`.
- **Phân tích cú pháp (`flutter analyze`):**
  - **Kết quả:** `No issues found! (0 errors, 0 warnings, 0 lints)`.
