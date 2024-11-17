import 'package:azkark/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'localization/app_localizations_delegate.dart';
import 'pages/home/home_page.dart';
import 'pages/home/loading_page.dart';
import 'providers/sections_provider.dart';
import 'util/app_theme.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
      GenerateMultiProvider(
        child:  const MyApp(),
      ));

}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//     ]);
//
//     return GenerateMultiProvider(
//
//       child: MaterialApp(
//         title: 'Azkar',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.appTheme(context),
//         localizationsDelegates: [
//           const AppLocalizationsDelegate(),
//           GlobalMaterialLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//         ],
//         supportedLocales: AppLocalizationsDelegate.supportedLocales(),
//         localeResolutionCallback: AppLocalizationsDelegate.resolution,
//         home: Consumer<SectionsProvider>(
//             builder: (context, sectionProvider, widget) {
//           return sectionProvider.isNewUser
//               ? FutureBuilder(
//                   future: sectionProvider.tryToGetData(context),
//                   builder: (context, result) {
//                     if (result.connectionState == ConnectionState.waiting) {
//                       print(' The page is  Loading !!');
//                       return LoadingPage();
//                     } else {
//                       print(' Username is Hemeda ');
//                       return HomePage();
//                       // return HomePage();
//                     }
//                   },
//                 )
//               : HomePage();
//         }),
//       ),
//     );
//   }
// }
