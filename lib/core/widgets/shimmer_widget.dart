import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/color_constants.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.baseColor,
    this.highlightColor,
  });

  factory ShimmerWidget.rectangular({
    required double width,
    required double height,
    double borderRadius = 8.0,
  }) {
    return ShimmerWidget(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  factory ShimmerWidget.circular({
    required double size,
  }) {
    return ShimmerWidget(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? ColorConstants.surface1,
      highlightColor: highlightColor ?? ColorConstants.surface2,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}