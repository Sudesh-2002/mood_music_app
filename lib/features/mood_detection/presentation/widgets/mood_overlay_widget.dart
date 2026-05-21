import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/mood_detection_bloc.dart';
import '../bloc/mood_detection_state.dart';

class MoodOverlayWidget extends StatefulWidget {
  const MoodOverlayWidget({super.key});

  @override
  State<MoodOverlayWidget> createState() => _MoodOverlayWidgetState();
}

class _MoodOverlayWidgetState extends State<MoodOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoodDetectionBloc, MoodDetectionState>(
      builder: (context, state) {
        final isScanning = state is MoodDetectionReady && state.isScanning ||
            state is MoodDetected;

        return Center(
          child: ScaleTransition(
            scale: _pulseAnim,
            child: CustomPaint(
              size: const Size(260, 320),
              painter: _FaceFramePainter(
                color: isScanning ? AppColors.primary : Colors.white54,
                isScanning: isScanning,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FaceFramePainter extends CustomPainter {
  final Color color;
  final bool isScanning;

  _FaceFramePainter({required this.color, required this.isScanning});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornerSize = 30.0;
    final r = Radius.circular(8);

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerSize)
        ..lineTo(0, r.x)
        ..arcToPoint(Offset(r.x, 0), radius: r)
        ..lineTo(cornerSize, 0),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, 0)
        ..lineTo(size.width - r.x, 0)
        ..arcToPoint(Offset(size.width, r.x), radius: r)
        ..lineTo(size.width, cornerSize),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerSize)
        ..lineTo(0, size.height - r.x)
        ..arcToPoint(Offset(r.x, size.height), radius: r)
        ..lineTo(cornerSize, size.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, size.height)
        ..lineTo(size.width - r.x, size.height)
        ..arcToPoint(Offset(size.width, size.height - r.x), radius: r)
        ..lineTo(size.width, size.height - cornerSize),
      paint,
    );

    // Scan line when active
    if (isScanning) {
      final scanPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        scanPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_FaceFramePainter old) =>
      old.color != color || old.isScanning != isScanning;
}