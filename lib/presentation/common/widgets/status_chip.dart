import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, text, label) = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  (Color bg, Color text, String label) _config(String s) => switch (s) {
        'pending' => (AppColors.pendingBg, AppColors.pendingText, 'Pending'),
        'approved' || 'confirmed' => (AppColors.approvedBg, AppColors.approvedText, s == 'approved' ? 'Approved' : 'Confirmed'),
        'rejected' => (AppColors.rejectedBg, AppColors.rejectedText, 'Rejected'),
        'canceled' => (AppColors.canceledBg, AppColors.canceledText, 'Canceled'),
        'completed' => (AppColors.completedBg, AppColors.completedText, 'Completed'),
        _ => (AppColors.canceledBg, AppColors.canceledText, s),
      };
}
