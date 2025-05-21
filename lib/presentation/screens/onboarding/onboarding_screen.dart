import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = "/onboarding-screen";
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  // Nên khởi tạo List<Timer?> với độ dài bằng số lượng trang
  // List<Timer?> _timers = [null, null]; // Sẽ cập nhật dựa trên _titles.length

  final List<String> _titles = [
    'Welcome To\nExpense Manager',
    // !!! SỬA LỖI CHÍNH TẢ Ở ĐÂY !!!
    'Are You Ready To\nTake Control Of Your Finances?',
  ];
  final List<String> _svgs = [
    'assets/FunctionalIcon/Onboarding.svg', // KIỂM TRA KỸ ĐƯỜNG DẪN NÀY
    'assets/FunctionalIcon/Onboarding-1.svg', // KIỂM TRA KỸ ĐƯỜNG DẪN NÀY
  ];

  // Khởi tạo _timers dựa trên số lượng trang
  late List<Timer?> _timers;

  @override
  void initState() {
    super.initState();
    // Khởi tạo _timers với kích thước phù hợp
    _timers = List.generate(_titles.length, (_) => null);
    // Bắt đầu tự động chuyển cho trang đầu tiên
    if (_titles.isNotEmpty) {
      _startAutoNext(0, const Duration(seconds: 3));
    }
  }

  void _startAutoNext(int page, Duration duration) {
    if (page < 0 || page >= _timers.length) return; // Kiểm tra giới hạn

    _timers[page]?.cancel(); // Hủy timer cũ của trang đó (nếu có)
    _timers[page] = Timer(duration, () {
      // Chỉ chuyển trang nếu widget còn mounted và vẫn đang ở trang đó
      if (mounted && _currentPage == page) {
        _goToPage(page + 1);
      }
    });
  }

  void _goToPage(int page) {
    if (page < _titles.length) {
      // So sánh với tổng số trang
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    } else {
      // Hết onboarding, sang splash B
      // Đảm bảo route '/splash-b' đã được định nghĩa trong GoRouter
      if (mounted) {
        context.go('/splash-b');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var timer in _timers) {
      timer?.cancel();
    }
    super.dispose();
  }

  Widget _buildOnboardingPage(
    int index,
    double screenHeight,
    double screenWidth,
  ) {
    return Column(
      children: [
        // Phần trên: nền xanh, tiêu đề
        Container(
          width: screenWidth,
          height: screenHeight * 2 / 5,
          color: AppColors.caribbeanGreen,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _titles[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24, // Có thể điều chỉnh cho phù hợp với thiết kế
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // Phần dưới: container trắng bo góc trên, SVG, nút, dot
        Container(
          width: screenWidth,
          height: screenHeight * 3 / 5,
          decoration: const BoxDecoration(
            // !!! THỬ THAY BẰNG MÀU NỔI BẬT ĐỂ KIỂM TRA NẾU KHÔNG THẤY !!!
            // color: Colors.red, // VÍ DỤ
            color: AppColors.honeydew, // Đảm bảo màu này đúng và tương phản
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(48), // Bo góc như thiết kế
              topRight: Radius.circular(48),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 32, // Điều chỉnh padding nếu cần
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Để nút và dots ở dưới
              children: [
                Expanded(
                  // SVG chiếm không gian còn lại ở giữa
                  child: Center(
                    child: SvgPicture.asset(
                      _svgs[index],
                      width: screenWidth * 0.7,
                      height: screenHeight * 0.22,
                      fit: BoxFit.contain,
                      placeholderBuilder:
                          (context) => const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.caribbeanGreen,
                            ),
                          ),
                      // THÊM errorBuilder để debug nếu SVG không tải được
                      // errorBuilder: (context, error, stackTrace) =>
                      //     const Icon(Icons.error, color: Colors.red, size: 50),
                    ),
                  ),
                ),
                // Phần nút và dots
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caribbeanGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50, // Tăng padding ngang cho nút rộng hơn
                          vertical: 15, // Tăng padding dọc
                        ),
                        minimumSize: Size(
                          screenWidth * 0.6,
                          50,
                        ), // Kích thước tối thiểu cho nút
                      ),
                      onPressed:
                          () => _goToPage(
                            index + 1,
                          ), // Dùng index + 1 an toàn hơn
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Tăng khoảng cách
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _titles.length,
                        (i) => _buildDot(i == index), // Dùng index
                      ),
                    ),
                    const SizedBox(height: 16), // Khoảng cách với đáy
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ), // Tăng khoảng cách giữa các dot
      width: active ? 12 : 8, // Dot active to hơn
      height: active ? 12 : 8,
      decoration: BoxDecoration(
        color:
            active
                ? AppColors.caribbeanGreen
                : AppColors.caribbeanGreen.withValues(
                  alpha: (0.3 * 255).round().toDouble(),
                ),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Quan trọng: Wrap PageView.builder bằng Scaffold để có nền mặc định
    // và để các widget như Text, Container có thể hiển thị đúng.
    return Scaffold(
      // backgroundColor: AppColors.caribbeanGreen, // Bạn có thể muốn nền chung là màu xanh
      body: PageView.builder(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Không cho phép vuốt tay
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
          // Hủy timer cũ của trang trước đó (nếu có) và khởi động timer cho trang mới
          // Điều này quan trọng để tránh nhiều timer chạy cùng lúc hoặc timer cũ kích hoạt chuyển trang sai
          for (int i = 0; i < _timers.length; i++) {
            if (i != index) {
              _timers[i]?.cancel();
            }
          }
          _startAutoNext(index, const Duration(seconds: 3));
        },
        itemCount: _titles.length,
        itemBuilder:
            (context, index) =>
                _buildOnboardingPage(index, screenHeight, screenWidth),
      ),
    );
  }
}
