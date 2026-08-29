import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

enum DeviceScreenType { mobile, tablet, desktop }

class SizingInformation {
  const SizingInformation({
    required this.screenSize,
    required this.localWidgetSize,
    required this.deviceScreenType,
  });

  final Size screenSize;
  final Size localWidgetSize;
  final DeviceScreenType deviceScreenType;

  bool get isMobile => deviceScreenType == DeviceScreenType.mobile;
  bool get isTablet => deviceScreenType == DeviceScreenType.tablet;
  bool get isDesktop => deviceScreenType == DeviceScreenType.desktop;
}

DeviceScreenType getDeviceType(double width) {
  if (width >= AppBreakpoints.tablet) {
    return DeviceScreenType.desktop;
  }

  if (width >= AppBreakpoints.mobile) {
    return DeviceScreenType.tablet;
  }

  return DeviceScreenType.mobile;
}

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(
      BuildContext context, SizingInformation sizingInformation) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.sizeOf(context);
        final localSize = Size(
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : screenSize.width,
          constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : screenSize.height,
        );

        final sizingInformation = SizingInformation(
          screenSize: screenSize,
          localWidgetSize: localSize,
          deviceScreenType: getDeviceType(localSize.width),
        );

        return builder(context, sizingInformation);
      },
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.isDesktop) {
          return desktop ?? tablet ?? mobile;
        }

        if (sizingInformation.isTablet) {
          return tablet ?? mobile;
        }

        return mobile;
      },
    );
  }
}

class MaxContentWidth extends StatelessWidget {
  const MaxContentWidth({
    super.key,
    required this.child,
    this.maxWidth = 1280,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.tablet = const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    this.desktop = const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
  });

  final Widget child;
  final EdgeInsets mobile;
  final EdgeInsets tablet;
  final EdgeInsets desktop;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final padding = sizingInformation.isDesktop
            ? desktop
            : sizingInformation.isTablet
                ? tablet
                : mobile;

        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}

double responsiveValue(
  SizingInformation sizingInformation, {
  required double mobile,
  double? tablet,
  double? desktop,
}) {
  if (sizingInformation.isDesktop) {
    return desktop ?? tablet ?? mobile;
  }

  if (sizingInformation.isTablet) {
    return tablet ?? mobile;
  }

  return mobile;
}

int responsiveGridCount({
  required double availableWidth,
  required double minItemWidth,
  required double spacing,
  int maxColumns = 5,
}) {
  final columnCount =
      ((availableWidth + spacing) / (minItemWidth + spacing)).floor();
  return math.max(1, math.min(maxColumns, columnCount));
}
