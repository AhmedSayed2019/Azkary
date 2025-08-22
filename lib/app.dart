
import 'package:azkark/pages/home/loading_page.dart';
import 'package:azkark/providers/sections_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';


import 'localization/app_localizations_delegate.dart';
import 'pages/home/home_page.dart';
import 'util/app_theme.dart';

BuildContext? appContext;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    appContext = context;
    return MaterialApp(

      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizationsDelegate.supportedLocales(),
      localeResolutionCallback: AppLocalizationsDelegate.resolution,


      theme: AppTheme.appTheme(context),
      // theme: lightTheme,
      color:Theme.of(context).scaffoldBackgroundColor,


      title: 'أذكار المسلم',
      debugShowCheckedModeBanner: false,

      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Consumer<SectionsProvider>(
            builder: (context, sectionProvider, widget) {
              return sectionProvider.isNewUser
                  ? FutureBuilder(
                future: sectionProvider.tryToGetData(context),
                builder: (context, result) {
                  if (result.connectionState == ConnectionState.waiting) {
                    print(' The page is  Loading !!');
                    return LoadingPage();
                  } else {
                    print(' Username is Hemeda ');
                    return HomePage();
                    // return HomePage();
                  }
                },
              )
                  : HomePage();
            }),
      ),
    );
  }
}
