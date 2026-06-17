import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Data class for a single navigation item.
class AppNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// A premium, floating pill-style bottom navigation bar that matches the
/// Sport Energy design system (AppColors.finOrange accent, Inter typography,
/// light & dark theme aware).
///
/// Usage:
/// ```dart
/// AppBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (i) => setState(() => _currentIndex = i),
///   items: const [
///     AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
///     AppNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
///   ],
/// )
/// ```
class AppBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;

  /// Optional badge counts per item (0 = no badge, null = not shown).
  final List<int?>? badgeCounts;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.badgeCounts,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  static const Color _accentColor = Color(0xFFFF5600);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AppBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;
    HapticFeedback.selectionClick();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE3DED7);
    final unselectedColor = isDark ? const Color(0xFF6E6E6E) : const Color(0xFF9C9FA5);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (index) {
              final item = widget.items[index];
              final isSelected = index == widget.currentIndex;
              final badgeCount = widget.badgeCounts != null &&
                      index < widget.badgeCounts!.length
                  ? widget.badgeCounts![index]
                  : null;

              return Expanded(
                child: _NavBarItem(
                  item: item,
                  isSelected: isSelected,
                  scaleAnim: isSelected ? _scaleAnim : const AlwaysStoppedAnimation(1.0),
                  accentColor: _accentColor,
                  unselectedColor: unselectedColor,
                  badgeCount: badgeCount,
                  onTap: () => _handleTap(index),
                  isDark: isDark,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final AppNavItem item;
  final bool isSelected;
  final Animation<double> scaleAnim;
  final Color accentColor;
  final Color unselectedColor;
  final int? badgeCount;
  final VoidCallback onTap;
  final bool isDark;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.scaleAnim,
    required this.accentColor,
    required this.unselectedColor,
    required this.badgeCount,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pillBg = isDark
        ? accentColor.withValues(alpha: 0.15)
        : accentColor.withValues(alpha: 0.10);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: scaleAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: isSelected ? scaleAnim.value : 1.0,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: isSelected ? pillBg : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: child,
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      key: ValueKey(isSelected),
                      color: isSelected ? accentColor : unselectedColor,
                      size: 22,
                    ),
                  ),
                  // Badge
                  if (badgeCount != null && badgeCount! > 0)
                    Positioned(
                      top: -5,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          badgeCount! > 99 ? '99+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? accentColor : unselectedColor,
              height: 1.2,
            ),
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}
