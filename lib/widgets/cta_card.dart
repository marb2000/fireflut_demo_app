import '../common_dependencies.dart';
import '../data_services/data_service_interface.dart';
import '../services/gemini_service.dart';
import '../views/chat_screen.dart';

class CtaCard extends StatefulWidget {
  final UserDataService dataService;
  final GeminiService geminiService;

  final String title;
  final String subtitle;

  const CtaCard({
    super.key,
    required this.dataService,
    required this.geminiService,
    required this.title,
    required this.subtitle,
  });

  @override
  State<CtaCard> createState() => _CtaCardState();
}

class _CtaCardState extends State<CtaCard> {
  final GlobalKey _cardKey = GlobalKey();
  Size? _cardSize;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    final double cardWidth = _cardSize?.width ?? 0;
    final double cardWidthHalf = cardWidth / 2;
    final double cardHeight = _cardSize?.height ?? 0;
    final double radialGradientRadiusFraction = 1.5;
    final double radialGradientRadius = cardHeight * radialGradientRadiusFraction;
    final double radiusOffsetMagic = 0.5;
    final double radialGradientAlignmentX =
        cardWidthHalf == 0 ? 0 : ((cardWidthHalf - (radialGradientRadius * radiusOffsetMagic)) / cardWidthHalf) * -1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
      Size? size = renderBox?.size;
      if (size?.width != _cardSize?.width || size?.height != _cardSize?.height) {
        setState(() {
          _cardSize = size;
        });
      }
    });

    return AppCard(
      key: _cardKey,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              dataService: widget.dataService,
              geminiService: widget.geminiService,
              openVoiceDialogOnInit: true,
            ),
          ),
        );
      },
      decorations: [
        BoxDecoration(
          gradient: LinearGradient(
            colors: [$styles.colors.secondary, $styles.colors.accent1],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        BoxDecoration(
          gradient: RadialGradient(
            colors: [$styles.colors.accent2.withValues(alpha: 0.65), $styles.colors.accent2.withValues(alpha: 0)],
            stops: [0.5, 1],
            radius: radialGradientRadiusFraction,
            center: Alignment(radialGradientAlignmentX, -0.8),
          ),
        )
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: textTheme.bodySmall?.copyWith(color: $styles.colors.background),
          ),
          SizedBox(height: $styles.insets.sm),
          Row(
            spacing: 32,
            children: [
              Expanded(
                child: Text(
                  widget.subtitle,
                  softWrap: true,
                  style: textTheme.titleMedium?.copyWith(
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 20.0,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        dataService: widget.dataService,
                        geminiService: widget.geminiService,
                        openVoiceDialogOnInit: true,
                      ),
                    ),
                  );
                },
                child: const Icon(
                  Icons.chevron_right,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
