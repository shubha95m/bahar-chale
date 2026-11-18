import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class AppSnackBar {
  AppSnackBar._();

  /// Shows a clean, polished SnackBar that auto-dismisses in 3 seconds
  /// and always provides a cross icon to dismiss immediately.
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger == null) return;

    scaffoldMessenger.hideCurrentSnackBar();

    Color bgColor = AppTheme.primaryGreen;
    IconData icon = Icons.check_circle_outline_rounded;

    if (isError) {
      bgColor = const Color(0xFFDC2626); // Tailwind Red-600
      icon = Icons.error_outline_rounded;
    } else if (isSuccess) {
      bgColor = const Color(0xFF16A34A); // Tailwind Green-600
      icon = Icons.task_alt_rounded;
    } else {
      bgColor = const Color(0xFF0F172A); // Slate-900 neutral
      icon = Icons.info_outline_rounded;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        duration: duration,
        showCloseIcon: true,
        closeIconColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.amberAccent,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
