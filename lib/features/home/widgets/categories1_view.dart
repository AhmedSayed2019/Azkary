// import 'package:azkark/features/compass/qibla_compass.dart';
// import 'package:azkark/generated/assets.dart';
// import 'package:azkark/pages/asmaallah/view_asmaallah.dart';
// import 'package:azkark/pages/favorites/view_favorites.dart';
// import 'package:azkark/pages/prayer/view_prayer.dart';
// import 'package:azkark/pages/quran/quran_screen.dart';
// import 'package:azkark/pages/sebha/items_sebha.dart';
// import 'package:azkark/pages/settings/settings_page.dart';
// import 'package:azkark/util/colors.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:azkark/util/navigate_between_pages/scale_route.dart';
// import 'package:flutter/material.dart';
//
// class HomeCategoriesView extends StatefulWidget {
//   const HomeCategoriesView({Key? key}) : super(key: key);
//
//   @override
//   State<HomeCategoriesView> createState() => _HomeCategoriesViewState();
// }
//
// class _HomeCategoriesViewState extends State<HomeCategoriesView> {
//
//   Widget _buildItemsCard({required BuildContext context,required String text, required String pathIcon,required GestureTapCallback? onTap}) {
//     final size = MediaQuery.of(context).size;
//     return Column(
//       children: <Widget>[
//         Card(
//           color: Theme.of(context).cardColor,
//           shape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           child: InkWell(
//             highlightColor: teal[400],
//             borderRadius: BorderRadius.circular(10),
//             onTap: onTap,
//             child: Container(
//               margin: const EdgeInsets.all(10.0),
//               height: size.height * 0.1,
//               width: size.width * 0.15,
//               child: pathIcon == '0'
//                   ? Icon(
//                 Icons.settings,
//                 color: const Color(0xff414441),
//                 size: size.width * 0.12,
//               )
//                   : Image.asset(
//                 pathIcon,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ),
//         SizedBox(
//           width: size.width * 0.18,
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: teal,
//               fontWeight: FontWeight.w700,
//               fontSize: 13,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Container(
//       height: size.height * 0.25,
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: _buildItemsCard(
//               context: context,
//               text: tr( 'favorite_bar'),
//               pathIcon: 'assets/images/icons/favorites/favorite_256px.png',
//               onTap: () => Navigator.push(
//                 context,
//                 ScaleRoute(page: FavoritesView()),
//               ),
//             ),
//           ),
//           _buildItemsCard(
//             context: context,
//             text: tr( 'quran'),
//             pathIcon: Assets.sectionsQuran,
//             onTap: () => Navigator.push(context, ScaleRoute(page: const QuranListScreen())),
//           ),
//
//           _buildItemsCard(
//             context: context,
//             text: tr( 'sebha_bar'),
//             pathIcon: 'assets/images/icons/sebha/sebha_256px.png',
//             onTap: () => Navigator.push(
//               context,
//               ScaleRoute(page: ItemsSebha()),
//             ),
//           ),
//           _buildItemsCard(
//             context: context,
//             text: tr( 'compass'),
//             pathIcon: Assets.sectionsCampass,
//             onTap: () => Navigator.push(context, ScaleRoute(page: const CompassWithQibla())),
//
//           ),
//           _buildItemsCard(
//             context: context,
//             text: tr( 'prayer_bar'),
//             pathIcon: 'assets/images/icons/prayer/prayer_256px.png',
//             onTap: () => Navigator.push(
//               context,
//               ScaleRoute(page: ViewPrayer()),
//             ),
//           ),
//           _buildItemsCard(
//             context: context,
//             text: tr( 'asmaallah_bar'),
//             pathIcon: 'assets/images/icons/asmaallah/allah_256px.png',
//             onTap: () => Navigator.push(
//               context,
//               ScaleRoute(page: ViewAsmaAllah()),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: _buildItemsCard(
//               context: context,
//               text: tr( 'settings_bar'),
//               pathIcon: '0',
//               onTap: () => Navigator.push(
//                 context,
//                 ScaleRoute(page: Settings()),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
