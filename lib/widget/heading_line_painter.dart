import 'package:flutter/material.dart';
import 'dart:math' as math;

class HeadingLinePainter extends CustomPainter {
  final double angle;
  final Color color;
  final double lineLength;
  final bool showArrowIcon;

  HeadingLinePainter({
    required this.angle,
    this.color = const Color.fromARGB(255, 38, 35, 35),
    this.lineLength = 20.0,
    this.showArrowIcon = true,
  });

   @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Menggambar ikon panah jika diaktifkan
    if (showArrowIcon) {
      drawArrowIcon(canvas, center);
    }
  }
  
  // Fungsi untuk menggambar ikon panah
  void drawArrowIcon(Canvas canvas, Offset center) {
    final iconPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;
      
    final lineLength = 16.0;
    final arrowHeadWidth = 6.0;
    final arrowHeadHeight = 5.0;
    
    // Simpan state canvas saat ini
    canvas.save();
    
    // Translasi ke pusat dan rotasi sesuai dengan sudut kapal
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    
    // Menggambar garis
    canvas.drawLine(
      Offset(-lineLength/2, 0),
      Offset(lineLength/2 - arrowHeadWidth, 0),
      iconPaint
    );
    
    // Menggambar kepala panah
    final arrowHeadPath = Path();
    arrowHeadPath.moveTo(lineLength/2, 0);
    arrowHeadPath.lineTo(lineLength/2 - arrowHeadWidth, -arrowHeadHeight);
    arrowHeadPath.lineTo(lineLength/2 - arrowHeadWidth, arrowHeadHeight);
    arrowHeadPath.close();
    
    canvas.drawPath(arrowHeadPath, iconPaint);
    
    // Kembalikan state canvas
    canvas.restore();
  }
  // Fungsi untuk menggambar garis putus-putus
  void drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dashWidth = 2.0;
    final dashSpace = 2.0;
    
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    
    final unitVectorX = dx / distance;
    final unitVectorY = dy / distance;
    
    var currentX = start.dx;
    var currentY = start.dy;
    var distanceTraveled = 0.0;
    
    while (distanceTraveled < distance) {
      // Menggambar dash
      final dashEndX = currentX + unitVectorX * math.min(dashWidth, distance - distanceTraveled);
      final dashEndY = currentY + unitVectorY * math.min(dashWidth, distance - distanceTraveled);
      
      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(dashEndX, dashEndY),
        paint,
      );
      
      // Pindah ke posisi awal dash berikutnya
      distanceTraveled += dashWidth + dashSpace;
      currentX = start.dx + unitVectorX * distanceTraveled;
      currentY = start.dy + unitVectorY * distanceTraveled;
    }
  }

  @override
  bool shouldRepaint(HeadingLinePainter oldDelegate) {
    return oldDelegate.angle != angle || 
           oldDelegate.color != color ||
           oldDelegate.lineLength != lineLength ||
           oldDelegate.showArrowIcon != showArrowIcon;
  }
}