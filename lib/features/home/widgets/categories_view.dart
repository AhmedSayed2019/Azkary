import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/core/utils/helpers/extensions.dart';
import 'package:azkark/core/utils/helpers/gps_location_helper.dart';
import 'package:azkark/features/adhan/providers/location_provider.dart';
import 'package:azkark/features/quran/quran_screen.dart';
import 'package:azkark/features/refactor/asmaallah/presentation/modules/asma_allah_list/asma_allah_list_screen.dart';
import 'package:azkark/features/refactor/calender/presentation/modules/calendar/calendar_screen.dart';
import 'package:azkark/features/refactor/compass/presentation/modules/compass/compass_screen.dart';
import 'package:azkark/features/refactor/prayer/presentation/modules/prayer_list/prayer_list_screen.dart';
import 'package:azkark/features/refactor/sebha/presentation/modules/sebha_list/sebha_list_screen.dart';
import 'package:azkark/features/refactor/settings/presentation/modules/settings/settings_screen.dart';
import 'package:azkark/generated/assets.dart';
import 'package:azkark/pages/favorites/view_favorites.dart';
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
  Widget _buildItemsCard({
    required BuildContext context,
    required String text,
    required String pathIcon,
    required GestureTapCallback? onTap,
  }) {
    final size = MediaQuery.of(context).size;
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        highlightColor: teal[400],
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          height: size.height * 0.1,
          width: size.width,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: pathIcon == '0'
                      ? Icon(
                          Icons.settings,
                          color: const Color(0xff414441),
                          size: size.width * 0.15,
                        )
                      : Center(
                          child: Image.asset(
                            pathIcon,
                            fit: BoxFit.contain,
                            width: size.width * 0.15,
                            height: size.width * 0.15,
                          ),
                        ),
                ),
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle()
                    .semiBoldStyle(fontSize: 13)
                    .primaryTextColor() /*(color: teal, fontWeight: FontWeight.w700, fontSize: 13)*/, // Text(text, textAlign: TextAlign.center, style: const TextStyle().semiBoldStyle(fontSize: 13).customColor(AppColor.textColor.lightColor)/*(color: teal, fontWeight: FontWeight.w700, fontSize: 13)*/,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeItemsCard({
    required BuildContext context,
    required String text,
    required String pathIcon,
    required GestureTapCallback? onTap,
  }) {
    final size = MediaQuery.of(context).size;
    return Card(
      color: Theme.of(context).cardColor,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Image.asset(
                    pathIcon,
                    fit: BoxFit.contain,
                    width: size.width * 0.24,
                    height: size.width * 0.24,
                  ),
                ),
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle()
                    .semiBoldStyle(fontSize: 12)
                    .customColor(
                      teal,
                    ) /*(color: teal, fontWeight: FontWeight.w700, fontSize: 13)*/,
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
    final locationProvider = context.read<AdanLocationProvider>();

    // var quarterjsonData = context.watch<GetDataProvider>().quarterjsonData;
    // var widgejsonData = context.watch<GetDataProvider>().widgejsonData;
    return Column(
      children: [
        // _buildItemsCard(context: context, text: tr( 'quran'), pathIcon: Assets.sectionsQuran, onTap: () => Navigator.push(context, ScaleRoute(page:  const QuranPagesPro()))),

        GridView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: deviceWidth / 3,
            mainAxisSpacing: 4,
            childAspectRatio: 0.1,
            crossAxisSpacing: 4,
            mainAxisExtent: 110.h,
          ),
          children: <Widget>[
            _buildItemsCard(
              context: context,
              text: tr('quran'),
              pathIcon: Assets.sectionsQuran,
              onTap: () => Navigator.push(
                context,
                ScaleRoute(page: const QuranPagesPro()),
              ),
            ),
            // _buildItemsCard(context: context, text: tr( 'allReciters'), pathIcon: Assets.sectionsQuran, onTap: () => Navigator.push(context, ScaleRoute(page:  RecitersPage(/*jsonData: widgejsonData*/)))),

            _buildItemsCard(
              context: context,
              text: tr('favorite_bar'),
              pathIcon: Assets.favoritesFavorite256px,
              onTap: () =>
                  Navigator.push(context, ScaleRoute(page: FavoritesView())),
            ),

            _buildItemsCard(
              context: context,
              text: tr('sebha_bar'),
              pathIcon: Assets.sebhaSebha256px,
              onTap: () => Navigator.push(
                context,
                ScaleRoute(page: const SebhaListScreen()),
              ),
            ),
            _buildItemsCard(
              context: context,
              text: tr('qibla'),
              pathIcon: Assets.sectionsQibla,
              onTap: () => Navigator.push(
                context,
                ScaleRoute(page: const CompassScreen()),
              ),
            ),
            // _buildItemsCard(context: context, text: tr( 'qibla'), pathIcon: Assets.sectionsQibla, onTap: () => Navigator.push(context, ScaleRoute(page: const QiblaScreen()))),
            _buildItemsCard(
              context: context,
              text: tr('prayer_bar'),
              pathIcon: Assets.prayerPrayer256px,
              onTap: () => Navigator.push(
                context,
                ScaleRoute(page: const PrayerListScreen()),
              ),
            ),
            _buildItemsCard(
              context: context,
              text: tr('asmaallah_bar'),
              pathIcon: Assets.asmaallahAllah256px,
              onTap: () => Navigator.push(
                context,
                ScaleRoute(page: const AsmaAllahListScreen()),
              ),
            ),
            _buildItemsCard(
              context: context,
              text: tr('calender'),
              pathIcon: Assets.sectionsCalender,
              onTap: () => Navigator.push(
                context,
                ScaleRoute(page: const CalendarScreen()),
              ),
            ),
            // _buildItemsCard(context: context, text: tr( 'adan'), pathIcon:  Assets.sectionsAdan, onTap: () => Navigator.push(context, ScaleRoute(page: const AdhanScreen()))),
            _buildItemsCard(
              context: context,
              text: tr('nearby'),
              pathIcon: Assets.sectionsMosqueLocation,
              onTap: () => locationProvider.locationState is LocationAvailable
                  ? Uri.parse(
                      'https://www.google.com/maps/search/mosque+near+me/@${(locationProvider.locationState as LocationAvailable).locationInfo.latitude},${(locationProvider.locationState as LocationAvailable).locationInfo.longitude}',
                    )
                  : {
                      context.showSnackBar(tr('no_location_available')),
                      AdanLocationProvider.getInstance().init(),
                    },
            ),
            // _buildItemsCard(context: context, text: tr( 'nearby'), pathIcon:  Assets.sectionsMosqueLocation, onTap: () =>
            // locationProvider.locationState is LocationAvailable
            //     ? Navigator.push(context,
            //     ScaleRoute(page:  FeedbackTaker(
            //       'Nearby Mosque',
            //       'https://www.google.com/maps/search/mosque+near+me/@${(locationProvider.locationState as LocationAvailable).locationInfo.latitude},${(locationProvider.locationState as LocationAvailable).locationInfo.longitude}',
            //     ),
            //     ),)
            //     : context.showSnackBar(tr('no_location_available')),),
            _buildItemsCard(
              context: context,
              text: tr('settings_bar'),
              pathIcon: '0',
              onTap: () => Navigator.push(
                context,
                ScaleRoute(page: const SettingsScreen()),
              ),
            ),

            // _buildItemsCard(context: context, text: tr( 'notifications'), pathIcon: Assets.sectionsNotification, onTap: () => Navigator.push(context, ScaleRoute(page: const NotificationsPage()))),
          ],
        ),
      ],
    );
  }
}
