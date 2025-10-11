import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../utils/enhanced_animations.dart';

/// Enhanced UI widgets with animations and modern design
class EnhancedUIWidgets {
  
  // Enhanced Card with hover effects and animations
  static Widget enhancedCard({
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? padding,
    double? elevation,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    bool withHoverEffect = true,
    bool withShadow = true,
  }) {
    return Builder(
      builder: (context) {
        final theme = Provider.of<ThemeProvider>(context);
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor ?? theme.cardColor,
                  borderRadius: borderRadius ?? BorderRadius.circular(16),
                  boxShadow: withShadow ? [
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap != null ? () {
                      HapticFeedback.lightImpact();
                      onTap();
                    } : null,
                    borderRadius: borderRadius ?? BorderRadius.circular(16),
                    child: Padding(
                      padding: padding ?? const EdgeInsets.all(16),
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  // Enhanced Button with ripple effect
  static Widget enhancedButton({
    required String text,
    required VoidCallback onPressed,
    ButtonType type = ButtonType.primary,
    IconData? icon,
    bool isLoading = false,
    bool isEnabled = true,
    EdgeInsets? padding,
    double? width,
  }) {
    return Builder(
      builder: (context) {
        final theme = Provider.of<ThemeProvider>(context);
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: isEnabled ? 1.0 : 0.6),
          duration: const Duration(milliseconds: 200),
          builder: (context, opacity, child) {
            return Opacity(
              opacity: opacity,
              child: Container(
                width: width,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: type == ButtonType.primary ? LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                  ) : null,
                  border: type == ButtonType.outline ? Border.all(
                    color: theme.primaryColor,
                    width: 2,
                  ) : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isEnabled && !isLoading ? () {
                      HapticFeedback.mediumImpact();
                      onPressed();
                    } : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLoading) ...[
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  type == ButtonType.primary ? Colors.black : theme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ] else if (icon != null) ...[
                            Icon(
                              icon,
                              color: type == ButtonType.primary ? Colors.black : theme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            text,
                            style: TextStyle(
                              color: type == ButtonType.primary ? Colors.black : theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Enhanced Text Field with floating label
  static Widget enhancedTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Builder(
      builder: (context) {
        final theme = Provider.of<ThemeProvider>(context);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.borderColor),
                color: theme.cardColor,
              ),
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                validator: validator,
                enabled: enabled,
                style: TextStyle(color: theme.textColor),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: theme.subtleTextColor),
                  prefixIcon: prefixIcon != null ? Icon(
                    prefixIcon,
                    color: theme.subtleTextColor,
                  ) : null,
                  suffixIcon: suffixIcon != null ? IconButton(
                    icon: Icon(suffixIcon, color: theme.subtleTextColor),
                    onPressed: onSuffixTap,
                  ) : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Enhanced App Bar with gradient
  static PreferredSizeWidget enhancedAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    double elevation = 0,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Builder(
        builder: (context) {
          final theme = Provider.of<ThemeProvider>(context);
          
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.backgroundColor,
                  theme.backgroundColor.withOpacity(0.8),
                ],
              ),
            ),
            child: AppBar(
              title: Text(
                title,
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: centerTitle,
              backgroundColor: Colors.transparent,
              elevation: elevation,
              leading: leading,
              actions: actions,
              iconTheme: IconThemeData(color: theme.textColor),
            ),
          );
        },
      ),
    );
  }

  // Enhanced Bottom Sheet
  static void showEnhancedBottomSheet({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Provider.of<ThemeProvider>(context);
        
        return Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.subtleTextColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child,
            ],
          ),
        );
      },
    );
  }

  // Enhanced Loading Indicator
  static Widget enhancedLoading({
    String? message,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = Provider.of<ThemeProvider>(context);
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        color ?? theme.primaryColor,
                      ),
                    ),
                  );
                },
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    color: theme.subtleTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Enhanced Snackbar
  static void showEnhancedSnackbar({
    required BuildContext context,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
    String? actionLabel,
  }) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case SnackbarType.error:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case SnackbarType.warning:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case SnackbarType.info:
        backgroundColor = theme.primaryColor;
        textColor = Colors.black;
        icon = Icons.info;
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: action != null && actionLabel != null ? SnackBarAction(
          label: actionLabel,
          textColor: textColor,
          onPressed: action,
        ) : null,
      ),
    );
  }

  // Enhanced Search Bar
  static Widget enhancedSearchBar({
    required TextEditingController controller,
    required Function(String) onChanged,
    String hint = 'Search...',
    VoidCallback? onClear,
  }) {
    return Builder(
      builder: (context) {
        final theme = Provider.of<ThemeProvider>(context);
        
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: theme.borderColor),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(color: theme.textColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: theme.subtleTextColor),
              prefixIcon: Icon(Icons.search, color: theme.subtleTextColor),
              suffixIcon: controller.text.isNotEmpty ? IconButton(
                icon: Icon(Icons.clear, color: theme.subtleTextColor),
                onPressed: onClear ?? () {
                  controller.clear();
                  onChanged('');
                },
              ) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        );
      },
    );
  }
}

enum ButtonType { primary, outline, text }
enum SnackbarType { success, error, warning, info }

// Pull to refresh wrapper
class EnhancedRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const EnhancedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? theme.primaryColor,
      backgroundColor: theme.cardColor,
      child: child,
    );
  }
}
