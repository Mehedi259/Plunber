import 'package:flutter/material.dart';

class NavBarItem {
  final IconData icon;
  final String label;

  const NavBarItem({required this.icon, required this.label});
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
    NavBarItem(icon: Icons.work_outline, label: 'Job'),
    NavBarItem(icon: Icons.calendar_month_outlined, label: 'Calendar'),
    NavBarItem(icon: Icons.local_shipping_outlined, label: 'Vehicle'),
    NavBarItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4500), Color(0xFFFF6A00)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4500).withOpacity(0.4),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _items[index].icon,
                    color: isSelected
                        ? const Color(0xFFFF4500)
                        : Colors.white,
                    size: 24,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      _items[index].label,
                      style: const TextStyle(
                        color: Color(0xFFFF4500),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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