import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum SnackType { success, error, info }

void showAppSnackBar(BuildContext context, String message, {SnackType type = SnackType.info}) {
  final (color, icon) = switch (type) {
    SnackType.success => (AppColors.success, Icons.check_circle),
    SnackType.error => (AppColors.error, Icons.cancel),
    SnackType.info => (AppColors.gold, Icons.info),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: AppColors.white))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
}
