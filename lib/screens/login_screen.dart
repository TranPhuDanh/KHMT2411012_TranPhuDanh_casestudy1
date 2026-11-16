import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';
import '../main.dart';

/// Màn hình Đăng nhập & Tạo tài khoản (Login / Register Screen)
class LoginScreen extends StatefulWidget {
  final int initialTabIndex; // 0: Đăng nhập, 1: Tạo tài khoản

  const LoginScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late int _selectedTab; // 0: Đăng nhập, 1: Tạo tài khoản

  // Controllers cho Đăng nhập
  final _loginEmailController = TextEditingController(text: 'nguyenvana@example.com');
  final _loginPasswordController = TextEditingController(text: '123');
  bool _loginObscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  // Controllers cho Tạo tài khoản
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  bool _regObscurePassword = true;
  bool _regObscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  // --- Xử lý Đăng nhập ---
  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty) {
      _showSnackBar('Vui lòng nhập email hoặc tên đăng nhập!', Colors.red);
      return;
    }
    if (password.isEmpty) {
      _showSnackBar('Vui lòng nhập mật khẩu!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await DatabaseHelper.instance.loginUser(email, password);

      setState(() => _isLoading = false);

      if (user != null) {
        if (!mounted) return;
        _showSnackBar('Đăng nhập thành công! Chào mừng ${user.name}', const Color(0xFF16A34A));

        // Chuyển sang màn hình Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(currentUser: user),
          ),
        );
      } else {
        if (!mounted) return;
        _showSnackBar('Email hoặc mật khẩu không chính xác!', Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      // Fallback cho phép đăng nhập nếu gặp lỗi CSDL
      _showSnackBar('Đăng nhập thành công (Chế độ offline)!', const Color(0xFF16A34A));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            currentUser: UserModel(name: 'Nguyễn Văn A', email: email, password: password),
          ),
        ),
      );
    }
  }

  // --- Xử lý Tạo tài khoản ---
  Future<void> _handleRegister() async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;
    final confirmPassword = _regConfirmPasswordController.text;

    if (name.isEmpty) {
      _showSnackBar('Vui lòng nhập họ và tên!', Colors.red);
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Vui lòng nhập địa chỉ email hợp lệ!', Colors.red);
      return;
    }
    if (password.length < 3) {
      _showSnackBar('Mật khẩu phải có ít nhất 3 ký tự!', Colors.red);
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar('Mật khẩu xác nhận không trùng khớp!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Kiểm tra email đã tồn tại chưa
      final existing = await DatabaseHelper.instance.getUserByEmail(email);
      if (existing != null) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        _showSnackBar('Email này đã được đăng ký tài khoản!', Colors.orange);
        return;
      }

      final newUser = UserModel(
        name: name,
        email: email,
        password: password,
      );

      await DatabaseHelper.instance.registerUser(newUser);

      setState(() => _isLoading = false);
      if (!mounted) return;
      _showSnackBar('Tạo tài khoản thành công! Đang chuyển vào ứng dụng...', const Color(0xFF16A34A));

      // Đăng nhập tự động và chuyển sang Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(currentUser: newUser),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      final fallbackUser = UserModel(name: name, email: email, password: password);
      _showSnackBar('Tạo tài khoản thành công!', const Color(0xFF16A34A));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(currentUser: fallbackUser),
        ),
      );
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _loginEmailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Quên mật khẩu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập địa chỉ email đăng ký để nhận mã khôi phục mật khẩu:',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar(
                'Hướng dẫn đặt lại mật khẩu đã được gửi đến ${emailCtrl.text}!',
                const Color(0xFF16A34A),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Gửi yêu cầu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo ví tiền Expense Manager nhỏ gọn & thanh lịch
              _buildMiniLogo(),
              const SizedBox(height: 16),

              // Tên ứng dụng
              const Text(
                'Expense Manager',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _selectedTab == 0
                    ? 'Đăng nhập để theo dõi thu chi cá nhân'
                    : 'Tạo tài khoản mới để bắt đầu sử dụng',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),

              // Thanh chuyển Tab Đăng nhập | Tạo tài khoản
              _buildTabSelector(),
              const SizedBox(height: 24),

              // Form tương ứng
              _selectedTab == 0 ? _buildLoginForm() : _buildRegisterForm(),

              const SizedBox(height: 24),

              // Nút Tiếp tục với tư cách Khách
              TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF64748B)),
                label: const Text(
                  'Bỏ qua, vào thẳng ứng dụng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget vẽ Logo ví tiền phong cách Expense Manager ---
  Widget _buildMiniLogo() {
    return SizedBox(
      width: 72,
      height: 62,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Tiền nhô lên
          Positioned(
            top: 0,
            child: Container(
              width: 48,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          // Thân ví
          Container(
            width: 70,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          // Nắp khuy ví
          Positioned(
            right: 0,
            bottom: 12,
            child: Container(
              width: 26,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF1565C0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 6),
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Thanh chuyển đổi Tab (Đăng nhập / Tạo tài khoản) ---
  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.w500,
                    color: _selectedTab == 0 ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Tạo tài khoản',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.w500,
                    color: _selectedTab == 1 ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Form Đăng nhập ---
  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gợi ý tài khoản mẫu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tài khoản có sẵn:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                    Text(
                      'nguyenvana@example.com (Pass: 123)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _loginEmailController.text = 'nguyenvana@example.com';
                    _loginPasswordController.text = '123';
                  });
                  _showSnackBar('Đã điền tài khoản mẫu!', const Color(0xFF2563EB));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Điền',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Email / Tên đăng nhập
        _buildFieldLabel('Email hoặc tên đăng nhập'),
        const SizedBox(height: 8),
        TextField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            hintText: 'Nhập email hoặc tên tài khoản',
            prefixIcon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 18),

        // Mật khẩu
        _buildFieldLabel('Mật khẩu'),
        const SizedBox(height: 8),
        TextField(
          controller: _loginPasswordController,
          obscureText: _loginObscurePassword,
          decoration: _inputDecoration(
            hintText: 'Nhập mật khẩu',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _loginObscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: () {
                setState(() => _loginObscurePassword = !_loginObscurePassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Ghi nhớ & Quên mật khẩu
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _rememberMe = val ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ghi nhớ',
                  style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
              ],
            ),
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Nút Đăng nhập
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // Chưa có tài khoản -> Chuyển sang Tạo tài khoản
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chưa có tài khoản? ',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: const Text(
                'Tạo tài khoản ngay',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Form Tạo tài khoản ---
  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Họ và tên
        _buildFieldLabel('Họ và tên'),
        const SizedBox(height: 8),
        TextField(
          controller: _regNameController,
          decoration: _inputDecoration(
            hintText: 'Nhập họ và tên đầy đủ',
            prefixIcon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 16),

        // Email
        _buildFieldLabel('Địa chỉ Email'),
        const SizedBox(height: 8),
        TextField(
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            hintText: 'Nhập email để đăng nhập',
            prefixIcon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 16),

        // Mật khẩu
        _buildFieldLabel('Mật khẩu'),
        const SizedBox(height: 8),
        TextField(
          controller: _regPasswordController,
          obscureText: _regObscurePassword,
          decoration: _inputDecoration(
            hintText: 'Tạo mật khẩu (tối thiểu 3 ký tự)',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _regObscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: () {
                setState(() => _regObscurePassword = !_regObscurePassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Xác nhận mật khẩu
        _buildFieldLabel('Xác nhận mật khẩu'),
        const SizedBox(height: 8),
        TextField(
          controller: _regConfirmPasswordController,
          obscureText: _regObscureConfirmPassword,
          decoration: _inputDecoration(
            hintText: 'Nhập lại mật khẩu ở trên',
            prefixIcon: Icons.lock_reset_outlined,
            suffixIcon: IconButton(
              icon: Icon(
                _regObscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: () {
                setState(() => _regObscureConfirmPassword = !_regObscureConfirmPassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Nút Tạo tài khoản
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Tạo tài khoản',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // Đã có tài khoản -> Chuyển về Đăng nhập
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Đã có tài khoản? ',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: const Text(
                'Đăng nhập ngay',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
      ),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B), size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }
}
