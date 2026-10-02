import 'package:flutter/material.dart';
import 'package:mobile_barberstuff/core/theme/app_color.dart';

class NetworkAvatar extends StatelessWidget {
  const NetworkAvatar({super.key, required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? _fallback()
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                    _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() => ColoredBox(
    color: AppColor.border,
    child: Icon(
      Icons.person_rounded,
      size: size * 0.55,
      color: AppColor.surface,
    ),
  );
}
