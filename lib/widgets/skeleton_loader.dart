import 'package:fireflut_demo_app/common_dependencies.dart';

class SkeletonLoader extends StatelessWidget {
  final bool showText; // Add a parameter to control text visibility
  const SkeletonLoader({super.key, this.showText = true}); // Default to true

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showText) // Conditionally render the row with text
          Row(
            spacing: $styles.insets.sm,
            children: [
              Text("One moment…"),
            ],
          ),
          SizedBox(height: $styles.insets.xs),
          Column(
            spacing: $styles.insets.xs,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              2,
                  (index) => Container(
                width: MediaQuery.of(context).size.width *
                    (Random().nextDouble() * 0.15 + 0.75),
                height: 16.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      $styles.colors.primary,
                      $styles.colors.background,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              )
                  .animate(
                  onPlay: (controller) =>
                      controller.repeat(reverse: false))
                  .shimmer(
                duration: 1.seconds,
                blendMode: BlendMode.srcATop,
                angle: pi / 4,
              ),
            ),
          )
        ],
    ).animate().fadeIn(duration: 300.ms);
  }
}