import 'package:flutter/material.dart';

class NavBarItem {
  final String activeImage;
  final String inactiveImage;
  final String label;

  const NavBarItem({
    required this.activeImage,
    required this.inactiveImage,
    required this.label,
  });
}

class CustomNavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomNavBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const List<NavBarItem> _items = [
    NavBarItem(
      activeImage: 'assets/images/job_active.png',
      inactiveImage: 'assets/images/job_inactive.png',
      label: 'Job',
    ),
    NavBarItem(
      activeImage: 'assets/images/Calendar_active.png',
      inactiveImage: 'assets/images/calender_inactive.png',
      label: 'Calendar',
    ),
    NavBarItem(
      activeImage: 'assets/images/car_active.png',
      inactiveImage: 'assets/images/car_inactive.png',
      label: 'Vehicle',
    ),
    NavBarItem(
      activeImage: 'assets/images/profile_active.png',
      inactiveImage: 'assets/images/profile_inactive.png',
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF2563EB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final isSelected = index == selectedIndex;
          return _NavBarItemWidget(
            item: _items[index],
            isSelected: isSelected,
            onTap: () => onItemSelected(index),
          );
        }),
      ),
    );
  }
}

class _NavBarItemWidget extends StatefulWidget {
  final NavBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarItemWidget> createState() => _NavBarItemWidgetState();
}

class _NavBarItemWidgetState extends State<_NavBarItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_NavBarItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: widget.isSelected ? 84 : null,
        height: widget.isSelected ? 60 : null,
        padding: EdgeInsets.symmetric(
          horizontal: widget.isSelected ? 8 : 12,
          vertical: widget.isSelected ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                widget.isSelected
                    ? widget.item.activeImage
                    : widget.item.inactiveImage,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            if (widget.isSelected) ...[
              const SizedBox(height: 2),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.item.label,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
