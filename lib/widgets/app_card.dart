import '../common_dependencies.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.decorations, this.onTap});

  AppCard.withBackgroundColor({super.key, required this.child, required Color backgroundColor, this.onTap})
      : decorations = [
          BoxDecoration(
            color: backgroundColor,
          ),
        ];

  final List<BoxDecoration>? decorations;

  final VoidCallback? onTap;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final showShimmer = onTap != null;

    return InkWell(
      // delay calling onTap so you can actually see the InkWell effect when navigating away.
      onTap: onTap != null ? () => Future.delayed(100.milliseconds, onTap) : null,
      borderRadius: $styles.corners.lgRadius,
      child: Stack(
        children: [
          if (decorations != null)
            ...decorations!.map((decoration) => Positioned.fill(
                  child: Ink(
                    decoration: decoration.copyWith(
                      borderRadius: decoration.borderRadius ?? $styles.corners.lgRadius,
                    ),
                  ),
                )),
          Positioned.fill(
            child: Ink(
              decoration: BoxDecoration(
                border: GradientBoxBorder(
                  gradient: LinearGradient(colors: [
                    $styles.colors.foreground.withValues(alpha: 0.5),
                    $styles.colors.background.withAlpha(0),
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  width: 1,
                ),
                borderRadius: $styles.corners.lgRadius,
              ),
            ),
          ),
          if (showShimmer)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: $styles.corners.lgRadius,
                  color: $styles.colors.background,
                ),
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                    delay: 5.seconds,
                    duration: 1.seconds,
                    color: Colors.white.withValues(alpha: 0.3),
                    blendMode: BlendMode.srcIn,
                  ),
            ),
          Card(
            color: Colors.transparent,
            margin: EdgeInsets.all($styles.insets.sm),
            child: child,
          )
        ],
      ),
    );
  }
}
