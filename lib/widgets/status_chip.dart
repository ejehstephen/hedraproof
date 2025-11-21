import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (status.toLowerCase()) {
      case 'verified':
        bgColor = const Color(0xFF00D77F).withOpacity(0.2);
        textColor = const Color(0xFF00D77F);
        borderColor = const Color(0xFF00D77F).withOpacity(0.5);
        break;
      case 'pending':
        bgColor = const Color(0xFFFFA940).withOpacity(0.2);
        textColor = const Color(0xFFFFA940);
        borderColor = const Color(0xFFFFA940).withOpacity(0.5);
        break;
      case 'invalid':
        bgColor = const Color(0xFFFF5A6A).withOpacity(0.2);
        textColor = const Color(0xFFFF5A6A);
        borderColor = const Color(0xFFFF5A6A).withOpacity(0.5);
        break;
      default:
        bgColor = const Color(0xFFA0A0B3).withOpacity(0.2);
        textColor = const Color(0xFFA0A0B3);
        borderColor = const Color(0xFFA0A0B3).withOpacity(0.5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
