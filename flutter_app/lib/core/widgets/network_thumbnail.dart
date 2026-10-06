import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/ui_constants.dart';

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url.isEmpty
          ? _ThumbnailBox(width: width, height: height, child: const _NoImageIcon())
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (context, url) => _ThumbnailBox(
                width: width,
                height: height,
                child: const SizedBox(
                  width: UiConstants.thumbnailSpinnerSize,
                  height: UiConstants.thumbnailSpinnerSize,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => _ThumbnailBox(
                width: width,
                height: height,
                child: const _NoImageIcon(),
              ),
            ),
    );
  }
}

class _ThumbnailBox extends StatelessWidget {
  const _ThumbnailBox({required this.width, required this.height, this.child});

  final double width;
  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _NoImageIcon extends StatelessWidget {
  const _NoImageIcon();

  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.image_not_supported_outlined);
}
