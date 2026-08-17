import 'package:azkark/core/res/resources.dart';
import 'package:azkark/core/utils/messaging_helper.dart';
import 'package:azkark/features/adhan/providers/location_provider.dart';
// import 'package:azkark/features/QuranPages/bloc/player_bar_bloc.dart';
// import 'package:azkark/features/QuranPages/bloc/player_bloc_bloc.dart';
// import 'package:azkark/features/QuranPages/bloc/quran_page_player_bloc.dart';
import 'package:azkark/features/home/get_data/get_data.dart';
import 'package:azkark/features/home/widgets/categories_view.dart';
import 'package:azkark/features/home/widgets/date_view.dart';
import 'package:azkark/features/home/widgets/pray_time/provider/location_provider.dart';
import 'package:azkark/features/notifications/views/all_notification_page.dart';
import 'package:azkark/features/refactor/feedback/domain/entity/feedback_form_type.dart';
import 'package:azkark/features/refactor/feedback/presentation/modules/feedback_webview/feedback_webview_screen.dart';
import 'package:azkark/features/refactor/settings/presentation/modules/settings/settings_screen.dart';
import 'package:azkark/generated/assets.dart';
import 'package:azkark/initializeData.dart';
import 'package:azkark/permission.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:azkark/features/refactor/categories/presentation/modules/categories_list/categories_list_screen.dart';

import '../../../../../models/section_model.dart';
import '../../../../../pages/categories/categories_of_section.dart';
import '../../../../../pages/search/search_azkar.dart';
import '../../../../../providers/sections_provider.dart';
import '../../../../../util/background.dart';
import '../../../../../util/colors.dart';
import '../../../../../util/navigate_between_pages/fade_route.dart';
import '../../../../../util/navigate_between_pages/scale_route.dart';
import '../../../../../widgets/search_widget/search_bar.dart';

// final qurapPagePlayerBloc = QuranPagePlayerBloc();
// final playerPageBloc = PlayerBlocBloc();
// final playerbarBloc = PlayerBarBloc();

printYellow(text) {
  print('\x1B[33m$text\x1B[0m');
}
/////////////////////////////////////////////////////////////////////////////////////////////


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  void initState() {
    initHiveValues();
    // Provider.of<GetDataProvider>(context, listen: false).initialQuranPages(context);
    //notifications
    initMessaging();
    checkNotificationPermission();

    // PrayTimeLocationProvider
    AdanLocationProvider.getInstance().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sectionsProvider = Provider.of<SectionsProvider>(context, listen: false);

    return Stack(
      children: <Widget>[
        Background(),
        Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            title: Text(tr( 'home_bar'), style: TextStyle(color: teal[50], fontWeight: FontWeight.w700, fontSize: 18)),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.menu, color: teal[50]),
                onPressed: () => _showMenuBottomSheet(context),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              CustomSearchBar(title: '${tr( 'search_for_zekr')} . . . ', onTap: () => Navigator.push(context, FadeRoute(page: SearchForZekr()))),
              const HomeDateView(),
              Expanded(
                child: Padding(
                  padding: kScreenPadding,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                        // MqSalaahTimeWidget(),
                        const HomeCategoriesView(),
                        _buildAllAzkarCard('عرض كل الأذكار', context),
                        for (int i = 0; i < sectionsProvider.length; i += 2)
                          _buildRowCategories(sectionsProvider, i, context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMenuBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: teal[200],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildMenuTile(
                context: sheetContext,
                icon: Icons.settings,
                title: tr('settings_bar'),
                onTap: () => Navigator.push(context, ScaleRoute(page: const SettingsScreen())),
              ),
              _buildMenuTile(
                context: sheetContext,
                icon: Icons.notifications_none,
                title: tr('notifications'),
                onTap: () => Navigator.push(context, ScaleRoute(page: const NotificationsPage())),
              ),
              _buildMenuTile(
                context: sheetContext,
                icon: Icons.bug_report_outlined,
                title: tr('report_a_bug'),
                onTap: () => Navigator.push(context, ScaleRoute(page: const FeedbackWebviewScreen(formType: FeedbackFormType.bugReport))),
              ),
              _buildMenuTile(
                context: sheetContext,
                icon: Icons.lightbulb_outline,
                title: tr('request_a_feature'),
                onTap: () => Navigator.push(context, ScaleRoute(page: const FeedbackWebviewScreen(formType: FeedbackFormType.featureRequest))),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: teal),
      title: Text(title, style: const TextStyle().semiBoldStyle(fontSize: 15).primaryTextColor()),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildAllAzkarCard(String text, BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          highlightColor: teal[400],
          borderRadius: BorderRadius.circular(10),
          onTap: () => Navigator.push(context, FadeRoute(page: const CategoriesListScreen())),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(right: 5.0),
                  height: size.height * 0.06,
                  child: Image.asset(Assets.sections8128px, fit: BoxFit.contain),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style:  const TextStyle().semiBoldStyle( fontSize: size.width * 0.05).primaryTextColor(),
                    // style: TextStyle(
                    //   color: teal,
                    //   fontWeight: FontWeight.w700,
                    //   fontSize: size.width * 0.05,
                    // ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowCategories(SectionsProvider sectionsProvider, int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCategoryCard(sectionsProvider.getSection(index), context),
          _buildCategoryCard(sectionsProvider.getSection(index + 1), context),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(SectionModel sectionModel, BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Expanded(
      child: Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          height: size.height * 0.25,
          width: size.width * 0.45,
          child: InkWell(
            highlightColor: teal[400],
            borderRadius: BorderRadius.circular(10),
            onTap: () => Navigator.push(context, FadeRoute(page: CategoriesOfSection(sectionModel.id))),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(5.0),
                      width: size.width * 0.4,
                      child: Image.asset('assets/images/sections/${sectionModel.id}.png', fit: BoxFit.contain),
                    ),
                  ),
                  Text(sectionModel.name,
                    textAlign: TextAlign.center,
                    style:  const TextStyle().semiBoldStyle().primaryTextColor(),

                    // style: const TextStyle(
                    //     color: teal,
                    //     fontWeight: FontWeight.w700,
                    //     fontSize: 14)
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
