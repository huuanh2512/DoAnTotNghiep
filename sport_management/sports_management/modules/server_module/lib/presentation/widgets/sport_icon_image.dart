import 'package:flutter/material.dart';

class SportIconImage extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final double size;
  final Color? fallbackColor;
  final BoxFit fit;

  const SportIconImage({
    super.key,
    required this.imageUrl,
    this.fallbackIcon = Icons.sports_rounded,
    this.size = 32,
    this.fallbackColor,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return Icon(fallbackIcon, size: size, color: fallbackColor);
    }

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            Icon(fallbackIcon, size: size, color: fallbackColor),
      ),
    );
  }
}
