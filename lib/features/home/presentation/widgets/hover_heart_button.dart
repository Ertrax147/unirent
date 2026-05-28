import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unirent/features/home/presentation/providers/favorites_provider.dart';

class HoverHeartButton extends ConsumerStatefulWidget {
  final int index;
  final double iconSize;
  final double padding;

  const HoverHeartButton({
    super.key,
    required this.index,
    this.iconSize = 16,
    this.padding = 4.0,
  });

  @override
  ConsumerState<HoverHeartButton> createState() => _HoverHeartButtonState();
}

class _HoverHeartButtonState extends ConsumerState<HoverHeartButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(favoritesProvider).contains(widget.index);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          ref.read(favoritesProvider.notifier).toggleFavorite(widget.index);
        },
        child: Container(
          color: Colors.transparent, // Ensure gesture detector captures the whole area
          padding: EdgeInsets.all(widget.padding),
          child: Icon(
            isFavorite || _isHovered ? Icons.favorite : Icons.favorite_border,
            color: isFavorite || _isHovered ? Colors.red : Colors.grey,
            size: widget.iconSize,
          ),
        ),
      ),
    );
  }
}
