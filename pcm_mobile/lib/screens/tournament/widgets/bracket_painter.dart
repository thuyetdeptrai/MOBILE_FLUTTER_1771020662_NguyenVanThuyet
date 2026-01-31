import 'package:flutter/material.dart';

class BracketPainter extends CustomPainter {
  final List<dynamic> matches;
  final Color color;

  BracketPainter({required this.matches, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Logic vẽ các đường nối giữa các vòng đấu (Round)
    // Ở đây demo vẽ các đường nối đơn giản giữa các node
    // Trong thực tế sẽ cần tính toán vị trí chính xác của từng Card trận đấu
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
