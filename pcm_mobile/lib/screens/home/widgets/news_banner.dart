import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/core.dart';

class NewsBanner extends StatefulWidget {
  const NewsBanner({super.key});

  @override
  State<NewsBanner> createState() => _NewsBannerState();
}

class _NewsBannerState extends State<NewsBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _news = [
    {
      'image': 'https://pickleballers.io/wp-content/uploads/2023/07/Pickleball-Tournament.webp',
      'title': 'Giải đấu Mùa Hè 2026 sắp khởi tranh!',
      'desc': 'Đăng ký ngay để nhận ưu đãi Early Bird giảm 20% phí tham gia.'
    },
    {
      'image': 'https://www.padeladdict.com/wp-content/uploads/2023/05/pickleball-court.jpg',
      'title': 'Ra mắt sân đấu mới: Sân Vô Cực',
      'desc': 'Trải nghiệm sân đấu đạt chuẩn quốc tế duy nhất tại khu vực.'
    },
    {
      'image': 'https://file.hstatic.net/200000287664/file/pickleball-la-gi_3f4b4f0f0f0f4f0f0f0f0f0f0f0f0f0f.jpg',
      'title': 'Ưu đãi nạp tiền tháng 2',
      'desc': 'Tặng thêm 10% khi nạp từ 500k qua VietQR.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _news.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            itemCount: _news.length,
            itemBuilder: (context, index) {
              return _buildBannerItem(_news[index]);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _news.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.accent : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(item['image']!),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => debugPrint('Image load error: $exception'),
        ),
      ),
      child: Stack(
        children: [
          // Fallback if image fails (DecorationImage doesn't have errorBuilder, so we stack)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 40)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('TIN NỔI BẬT', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['desc']!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
