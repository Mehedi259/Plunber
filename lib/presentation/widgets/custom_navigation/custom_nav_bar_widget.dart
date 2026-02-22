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
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

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
            color: const Color(0xFF2563EB).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onItemSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isSelected ? 84 : null,
              height: isSelected ? 60 : null,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 8 : 12,
                vertical: isSelected ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    isSelected
                        ? _items[index].activeImage
                        : _items[index].inactiveImage,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 2),
                    Text(
                      _items[index].label,
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}