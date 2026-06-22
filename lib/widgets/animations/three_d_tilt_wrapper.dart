import 'package:flutter/material.dart';

/// A premium widget that wraps its child in a 3D tilt effect.
/// It responds to mouse hover on desktop/web and touch/drag gestures on mobile.
/// It features a dynamic light shine reflection that shifts based on the tilt angle.
class ThreeDTiltWrapper extends StatefulWidget {
  final Widget child;
  final double maxTiltAngle; // Maximum tilt angle in degrees
  final double scaleOnTap; // Scale factor when hovered/tapped

  const ThreeDTiltWrapper({
    super.key,
    required this.child,
    this.maxTiltAngle = 10.0,
    this.scaleOnTap = 0.97,
  });

  @override
  State<ThreeDTiltWrapper> createState() => _ThreeDTiltWrapperState();
}

class _ThreeDTiltWrapperState extends State<ThreeDTiltWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _tiltX;
  late Animation<double> _tiltY;

  double _currentTiltX = 0.0;
  double _currentTiltY = 0.0;
  bool _isTapped = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _tiltX = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _tiltY = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateTilt(Offset localPosition, Size size) {
    // Normalize coordinates to range [-0.5, 0.5] relative to center
    final double xPercent = (localPosition.dx / size.width) - 0.5;
    final double yPercent = (localPosition.dy / size.height) - 0.5;

    // Convert degrees to radians
    final double maxRad = widget.maxTiltAngle * 3.141592653589793 / 180.0;

    setState(() {
      // Rotation around X axis is driven by vertical coordinates (inverted)
      _currentTiltX = (-yPercent * maxRad).clamp(-maxRad, maxRad);
      // Rotation around Y axis is driven by horizontal coordinates
      _currentTiltY = (xPercent * maxRad).clamp(-maxRad, maxRad);
    });
  }

  void _resetTilt() {
    _tiltX = Tween<double>(begin: _currentTiltX, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _tiltY = Tween<double>(begin: _currentTiltY, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward(from: 0.0).then((_) {
      setState(() {
        _currentTiltX = 0.0;
        _currentTiltY = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the layout constraints to determine actual rendering size
        final double width = constraints.maxWidth == double.infinity ? 200.0 : constraints.maxWidth;
        final double height = constraints.maxHeight == double.infinity ? 200.0 : constraints.maxHeight;
        final size = Size(width, height);

        return MouseRegion(
          onEnter: (_) {
            setState(() {
              _isHovered = true;
            });
          },
          onHover: (details) {
            _updateTilt(details.localPosition, size);
          },
          onExit: (_) {
            setState(() {
              _isHovered = false;
            });
            _resetTilt();
          },
          child: GestureDetector(
            onPanUpdate: (details) {
              _updateTilt(details.localPosition, size);
            },
            onPanEnd: (_) => _resetTilt(),
            onPanCancel: _resetTilt,
            onTapDown: (_) {
              setState(() {
                _isTapped = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                _isTapped = false;
              });
            },
            onTapCancel: () {
              setState(() {
                _isTapped = false;
              });
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double rotX =
                    _controller.isAnimating ? _tiltX.value : _currentTiltX;
                final double rotY =
                    _controller.isAnimating ? _tiltY.value : _currentTiltY;

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015) // Perspective parameter (gives 3D depth)
                    ..rotateX(rotX)
                    ..rotateY(rotY),
                  alignment: FractionalOffset.center,
                  child: AnimatedScale(
                    scale: _isTapped ? widget.scaleOnTap : (_isHovered ? 1.02 : 1.0),
                    duration: const Duration(milliseconds: 150),
                    child: Stack(
                      children: [
                        child!,
                        // Dynamic light reflection/shine overlay based on tilt direction
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: RadialGradient(
                                  center: Alignment(
                                    (rotY * 4.0).clamp(-1.0, 1.0),
                                    (-rotX * 4.0).clamp(-1.0, 1.0),
                                  ),
                                  radius: 1.0,
                                  colors: [
                                    Colors.white.withOpacity(0.08),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
