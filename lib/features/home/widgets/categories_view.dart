import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/features/QuranPagesTest/QuranPagesTest.dart';
import 'package:azkark/features/calender/calender.dart';
import 'package:azkark/features/compass/qibla_compass.dart';
import 'package:azkark/features/home/get_data/get_data.dart';
import 'package:azkark/generated/assets.dart';
import 'package:azkark/pages/asmaallah/view_asmaallah.dart';
import 'package:azkark/pages/favorites/view_favorites.dart';
import 'package:azkark/pages/prayer/view_prayer.dart';
import 'package:azkark/pages/sebha/items_sebha.dart';
import 'package:azkark/pages/settings/settings_page.dart';
import 'package:azkark/util/colors.dart';
import 'package:azkark/util/navigate_between_pages/scale_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeCategoriesView extends StatefulWidget {
  const HomeCategoriesView({Key? key}) : super(key: key);

  @override
  State<HomeCategoriesView> createState() => _HomeCategoriesViewState();
}

class _HomeCategoriesViewState extends State<HomeCategoriesView> {

  Widget _buildItemsCard({required BuildContext context,required String text, required String pathIcon,required GestureTapCallback? onTap}) {
    final size = MediaQuery.of(context).size;
    return Card(
      color: teal[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        highlightColor: teal[400],
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          height: size.height * 0.1,
          width: size.width,
          child: Column(
            children: [
              Expanded(
                child: Padding(padding: const EdgeInsets.all(8.0),
                    child: pathIcon == '0'
                        ? Icon(Icons.settings, color: const Color(0xff414441), size: size.width * 0.12)
                        : Center(child: Image.asset(pathIcon, fit: BoxFit.contain,width:  size.width * 0.16,height:  size.width * 0.16,)),
                ),
              ),
              Text(text, textAlign: TextAlign.center, style: const TextStyle().semiBoldStyle(fontSize: 12).customColor(teal)/*(color: teal, fontWeight: FontWeight.w700, fontSize: 13)*/,

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeItemsCard({required BuildContext context,required String text, required String pathIcon,required GestureTapCallback? onTap}) {
    final size = MediaQuery.of(context).size;
    return Card(
      color: teal[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        highlightColor: teal[400],
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          height: size.height * 0.1,
          width: size.width,
          child: Row(
            children: [
              Padding(padding: const EdgeInsets.all(8.0),
                  child: Center(child: Image.asset(pathIcon, fit: BoxFit.contain,width:  size.width * 0.24,height:  size.width * 0.24,)),
              ),
              Text(text, textAlign: TextAlign.center, style: const TextStyle().semiBoldStyle(fontSize: 12).customColor(teal)/*(color: teal, fontWeight: FontWeight.w700, fontSize: 13)*/,

              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var quarterjsonData = context.watch<GetDataProvider>().quarterjsonData;
    var widgejsonData = context.watch<GetDataProvider>().widgejsonData;

    return Column(
      children: [

        GridView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: deviceWidth/3,
            mainAxisSpacing: 4,
            childAspectRatio: 0.1,
            crossAxisSpacing:4,
            mainAxisExtent:110.h,
          ),
          children: <Widget>[
            // _buildItemsCard(context: context, text: tr( 'quran'), pathIcon: Assets.sectionsQuran, onTap: () => Navigator.push(context, ScaleRoute(page:  SurahListPage(jsonData: widgejsonData, quarterJsonData: quarterjsonData)))),
            _buildItemsCard(context: context, text: tr( 'quran'), pathIcon: Assets.sectionsQuran, onTap: () => Navigator.push(context, ScaleRoute(page:  QuranPagesTest()))),
            // _buildItemsCard(context: context, text: tr( 'allReciters'), pathIcon: Assets.sectionsQuran, onTap: () => Navigator.push(context, ScaleRoute(page:  RecitersPage(/*jsonData: widgejsonData*/)))),

            _buildItemsCard(context: context, text: tr( 'favorite_bar'), pathIcon: Assets.favoritesFavorite256px, onTap: () => Navigator.push(context, ScaleRoute(page: FavoritesView()))),

            _buildItemsCard(context: context, text: tr( 'sebha_bar'), pathIcon:  Assets.sebhaSebha256px, onTap: () => Navigator.push(context, ScaleRoute(page: ItemsSebha()))),
            _buildItemsCard(context: context, text: tr( 'compass'), pathIcon: Assets.sectionsCampass, onTap: () => Navigator.push(context, ScaleRoute(page: const QiblaCompassScreen()))),
            _buildItemsCard(context: context, text: tr( 'prayer_bar'), pathIcon: Assets.prayerPrayer256px, onTap: () => Navigator.push(context, ScaleRoute(page: ViewPrayer()))),
            _buildItemsCard(context: context, text: tr( 'asmaallah_bar'), pathIcon:  Assets.asmaallahAllah256px, onTap: () => Navigator.push(context, ScaleRoute(page: ViewAsmaAllah()))),
            _buildItemsCard(context: context, text: tr( 'calender'), pathIcon:  Assets.asmaallahAllah256px, onTap: () => Navigator.push(context, ScaleRoute(page: const CalenderPage()))),
            _buildItemsCard(context: context, text: tr( 'settings_bar'), pathIcon: '0', onTap: () => Navigator.push(context, ScaleRoute(page: Settings()))),
            // _buildItemsCard(context: context, text: tr( 'notifications'), pathIcon: Assets.sectionsQuran, onTap: () => Navigator.push(context, ScaleRoute(page: const NotificationsPage()))),

          ],
        ),
      ],
    );
  }
}
