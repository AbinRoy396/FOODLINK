import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced animation utilities for FoodLink app
class EnhancedAnimations {
  
  // Page transition animations with haptic feedback
  static Route<T> createRoute<T extends Object?>(
    Widget page, {
    AnimationType type = AnimationType.slideFromRight,
    Duration duration = const Duration(milliseconds: 350),
    bool withHaptic = true,
  }) {
    if (withHaptic) {
      HapticFeedback.lightImpact();
    }
    
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(type, animation, secondaryAnimation, child);
      },
    );
  }

  static Widget _buildTransition(
    AnimationType type,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (type) {
      case AnimationType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      
      case AnimationType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      
      case AnimationType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      
      case AnimationType.fadeScale:
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            )),
            child: child,
          ),
        );
      
      case AnimationType.morphing:
        return Stack(
          children: [
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.3, 0.0),
              ).animate(CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeInCubic,
              )),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 1.0,
                  end: 0.0,
                ).animate(CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: Curves.easeInCubic,
                )),
                child: Container(), // Previous page placeholder
              ),
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          ],
        );
    }
  }

  // Staggered list animation
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Bouncy button animation
  static Widget bouncyButton({
    required Widget child,
    required VoidCallback onTap,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: duration,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: (_) {
              HapticFeedback.lightImpact();
            },
            onTap: onTap,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Shimmer loading effect
  static Widget shimmerLoading({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 2.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor ?? Colors.grey[300]!,
                highlightColor ?? Colors.grey[100]!,
                baseColor ?? Colors.grey[300]!,
              ],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  // Floating Action Button with pulse animation
  static Widget pulsingFAB({
    required VoidCallback onPressed,
    required Widget child,
    Color? backgroundColor,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, scale, _) {
        return Transform.scale(
          scale: scale,
          child: FloatingActionButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onPressed();
            },
            backgroundColor: backgroundColor,
            child: child,
          ),
        );
      },
    );
  }

  // Card flip animation
  static Widget flipCard({
    required Widget front,
    required Widget back,
    required bool showFront,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: showFront ? 0.0 : 1.0),
      duration: duration,
      builder: (context, value, child) {
        if (value >= 0.5) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(3.14159),
            child: back,
          );
        } else {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * 3.14159),
            child: front,
          );
        }
      },
    );
  }

  // Progress indicator with animation
  static Widget animatedProgress({
    required double progress,
    Color? backgroundColor,
    Color? valueColor,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return LinearProgressIndicator(
          value: value,
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation(valueColor),
        );
      },
    );
  }

  // Typewriter text animation
  static Widget typewriterText({
    required String text,
    required TextStyle style,
    Duration duration = const Duration(milliseconds: 50),
  }) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: text.length),
      duration: Duration(milliseconds: duration.inMilliseconds * text.length),
      builder: (context, value, child) {
        return Text(
          text.substring(0, value),
          style: style,
        );
      },
    );
  }
}

enum AnimationType {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  fadeScale,
  morphing,
}

// Custom curve for bouncy animations
class BouncyCurve extends Curve {
  @override
  double transform(double t) {
    if (t < 0.5) {
      return 2 * t * t;
    } else {
      return -1 + (4 - 2 * t) * t;
    }
  }
}

// Hero animation helper
class HeroAnimationHelper {
  static Widget createHero({
    required String tag,
    required Widget child,
    Duration? flightTime,
  }) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (context, animation, direction, fromContext, toContext) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}

// Parallax scroll effect
class ParallaxWidget extends StatelessWidget {
  final Widget child;
  final double speed;
  final ScrollController scrollController;

  const ParallaxWidget({
    super.key,
    required this.child,
    required this.scrollController,
    this.speed = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, scrollController.offset * speed),
          child: this.child,
        );
      },
    );
  }
}
