import 'package:fireflut_demo_app/common_dependencies.dart';
import 'package:fireflut_demo_app/models/location_fact.dart';
import 'skeleton_loader.dart';

class LocationFactCard extends StatelessWidget {
  final LocationFact? fact;
  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  const LocationFactCard({
    super.key,
    required this.fact,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: Card(
        color: Colors.transparent,
        shape: Border(
          bottom: BorderSide(
            color: $styles.colors.border, // Choose your desired color
            width: 1.0, // Choose your desired width
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.language, size: 24),
                  const SizedBox(width: 8),
                  if (fact != null)
                    Expanded(
                      child: Text(
                        '${fact!.city}, ${fact!.country}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    constraints: const BoxConstraints(),
                    onPressed: isLoading ? null : onRefresh,
                  ),
                ],
              ),
              if (isLoading)
                const SkeletonLoader(showText: false)
              else if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              else if (fact != null)
                Text(
                  fact!.fact,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                  overflow: TextOverflow.visible,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
