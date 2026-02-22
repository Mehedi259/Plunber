// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../core/routes/route_path.dart';
//
// class CustomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int)? onTap;
//
//   const CustomNavBar({
//     Key? key,
//     required this.currentIndex,
//     this.onTap,
//   }) : super(key: key);
//
//   // ─── Figma base values (design canvas = 269 × 66) ────────────────────────
//   static const double _figmaW = 269.0;
//   static const double _figmaH = 66.0;
//
//   // Each slot occupies 51 px wide, starting at left=16
//   // Slot 0 left = 16,  Slot 1 = 67,  Slot 2 = 118,  Slot 3 = 169
//   static const List<double> _slotLefts = [16.0, 67.0, 118.0, 169.0];
//
//   static const List<String> _activeIcons = [
//     'assets/icons/Job_active.png',
//     'assets/icons/calender_active.png',
//     'assets/icons/Vehicle_active.png',
//     'assets/icons/profile_active.png',
//   ];
//
//   static const List<String> _labels = [
//     'Job',
//     'Calendar',
//     'Vehicle',
//     'Profile',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     // Navbar width = 72% of screen, clamped so it never looks broken
//     final navWidth = (screenWidth * 0.72).clamp(240.0, 320.0);
//
//     // Single scale factor keeps every Figma value in proportion
//     final scale = navWidth / _figmaW;
//     final navHeight = _figmaH * scale;
//
//     return SizedBox(
//       width: navWidth,
//       height: navHeight,
//       child: Container(
//         width: navWidth,
//         height: navHeight,
//         clipBehavior: Clip.antiAlias,
//         decoration: ShapeDecoration(
//           gradient: const LinearGradient(
//             begin: Alignment(0.51, -0.08),
//             end: Alignment(0.52, 1.94),
//             colors: [Color(0xFF2563EB), Colors.white],
//           ),
//           shape: RoundedRectangleBorder(
//             side: const BorderSide(
//               width: 1,
//               strokeAlign: BorderSide.strokeAlignOutside,
//               color: Color(0x33323232),
//             ),
//             borderRadius: BorderRadius.circular(48.0 * scale),
//           ),
//           shadows: const [
//             BoxShadow(
//               color: Color(0x28000000),
//               blurRadius: 6,
//               offset: Offset(0, 3),
//               spreadRadius: 0,
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             for (int i = 0; i < 4; i++)
//               _buildItem(index: i, scale: scale),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Active pill ─────────────────────────────────────────────────────────────
//   // Figma: left = slotLeft, top = 8, width = 84, height = 50
//   //
//   // ── Inactive icon ───────────────────────────────────────────────────────────
//   // Figma: icon 24×24, centered inside the 51-px slot, top = 21
//   Widget _buildItem({required int index, required double scale}) {
//     final isActive = currentIndex == index;
//
//     if (isActive) {
//       return Positioned(
//         left: _slotLefts[index] * scale,
//         top: 8.0 * scale,
//         child: GestureDetector(
//           onTap: () => onTap?.call(index),
//           behavior: HitTestBehavior.opaque,
//           child: Container(
//             width: 84.0 * scale,
//             height: 50.0 * scale,
//             padding: EdgeInsets.symmetric(
//               horizontal: 15.0 * scale,
//               vertical: 5.0 * scale,
//             ),
//             decoration: ShapeDecoration(
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(29.0 * scale),
//               ),
//               shadows: const [
//                 BoxShadow(
//                   color: Color(0x28000000),
//                   blurRadius: 6,
//                   offset: Offset(0, 3),
//                   spreadRadius: 0,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   _activeIcons[index],
//                   width: 24.0 * scale,
//                   height: 24.0 * scale,
//                   color: const Color(0xFF2563EB),
//                 ),
//                 SizedBox(height: 3.0 * scale),
//                 Text(
//                   _labels[index],
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: const Color(0xFF2563EB),
//                     fontSize: 12.0 * scale,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w400,
//                     height: 1.05,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     // Inactive: center 24px icon inside the 51px-wide slot
//     final iconSize = 24.0 * scale;
//     final slotWidth = 51.0 * scale;
//     final centeredLeft = _slotLefts[index] * scale + (slotWidth - iconSize) / 2;
//
//     return Positioned(
//       left: centeredLeft,
//       top: 21.0 * scale,
//       child: GestureDetector(
//         onTap: () => onTap?.call(index),
//         behavior: HitTestBehavior.opaque,
//         child: Image.asset(
//           _activeIcons[index],
//           width: iconSize,
//           height: iconSize,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }