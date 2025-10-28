import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kasi_hustle/core/theme/styles.dart';

enum TravelMode {
  walk('WALK', 'Walking', Ionicons.walk),
  drive('DRIVE', 'Driving', Ionicons.car),
  bicycle('BICYCLE', 'Cycling', Ionicons.bicycle);
  // twoWheeler(
  //   'TWO_WHEELER',
  //   'Motorcycle',
  //   Ionicons.bicycle,
  // ); // Using bicycle icon as fallback

  const TravelMode(this.apiValue, this.label, this.icon);
  final String apiValue;
  final String label;
  final IconData icon;
}

class TravelModeSelector extends StatefulWidget {
  final TravelMode initialMode;
  final ValueChanged<TravelMode> onModeChanged;

  const TravelModeSelector({
    super.key,
    required this.initialMode,
    required this.onModeChanged,
  });

  @override
  State<TravelModeSelector> createState() => _TravelModeSelectorState();
}

class _TravelModeSelectorState extends State<TravelModeSelector>
    with SingleTickerProviderStateMixin {
  late TravelMode _currentMode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _cycleToNextMode() {
    final currentIndex = TravelMode.values.indexOf(_currentMode);
    final nextIndex = (currentIndex + 1) % TravelMode.values.length;
    final nextMode = TravelMode.values[nextIndex];

    // Trigger pop animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _currentMode = nextMode;
    });
    widget.onModeChanged(nextMode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: _cycleToNextMode,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(Corners.med),
            border: Border.all(color: colorScheme.primary, width: 2),
            boxShadow: Shadows.small,
          ),
          child: Icon(
            _currentMode.icon,
            size: IconSizes.lg,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
