import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = isPrimary
        ? kPrimaryGradient
        : LinearGradient(colors: [kPrimaryColor.withOpacity(0.6), kAccentColor.withOpacity(0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    return AnimatedScale(
      scale: onPressed == null ? 1.0 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: kRadiusLarge,
          boxShadow: [
            BoxShadow(color: kAccentColor.withOpacity(0.22), blurRadius: 16, spreadRadius: 0, offset: const Offset(0, 6)),
            BoxShadow(color: kPrimaryColor.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: kRadiusLarge,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1), duration: 200.ms),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: kRadiusLarge,
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        backgroundBlendMode: BlendMode.srcOver,
      ),
      padding: padding,
      child: child,
    );
  }
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kSoftGradient,
        borderRadius: kRadiusLarge,
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 12)),
          BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class FocusProgressRing extends StatelessWidget {
  final double progress; // 0-1
  final double size;
  final String centerLabel;
  final Color activeColor;
  final Color completeColor;
  const FocusProgressRing({
    super.key,
    required this.progress,
    required this.centerLabel,
    this.size = 200,
    this.activeColor = kPrimaryColor,
    this.completeColor = kSuccessColor,
  });

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, v, _) {
              return CustomPaint(
                size: Size.square(size),
                painter: _RingPainter(progress: v, activeColor: activeColor, completeColor: completeColor),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerLabel,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color completeColor;
  _RingPainter({required this.progress, required this.activeColor, required this.completeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2 - strokeWidth;

    final bgPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final activePaint = Paint()
      ..color = progress >= 1.0 ? completeColor : activeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // background circle
    canvas.drawCircle(center, radius, bgPaint);
    // progress arc
    final startAngle = -3.14 / 2;
    final sweepAngle = 6.28 * progress;
    final rectArc = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rectArc, startAngle, sweepAngle, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}


