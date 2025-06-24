import '../common_dependencies.dart';

class BulbIcon extends StatelessWidget {
  const BulbIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return RadialGradient(
          colors: [Color(0xFFC8D9FF), Color(0xFF1B76FF)],
        ).createShader(bounds);
      },
      child: Icon(Icons.lightbulb, color: Colors.white),
    );
  }
}
