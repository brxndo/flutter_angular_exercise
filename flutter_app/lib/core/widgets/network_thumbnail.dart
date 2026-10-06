import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkThumbnail extends StatelessWidget {
  const NetworkThumbnail({
    required this.url,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    super.key,
  });

  final String url;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).colorScheme.surfaceContainerHighest;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: background,
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: background,
          child: const Icon(Icons.image_not_supported_outlined),
        ),
      ),
    );
  }
}
