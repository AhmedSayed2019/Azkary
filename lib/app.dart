
import 'package:azkark/core/localization/db_translations.dart';
import 'package:azkark/core/localization/app_locales.dart';
import 'dart:ui'as ui;

import 'package:azkark/core/res/theme/theme.dart';
import 'package:azkark/core/res/theme_helper.dart';
import 'package:azkark/features/home/home_page.dart';
import 'package:azkark/features/prayer/azan_alarm.dart';
import 'package:azkark/features/home/loading_page.dart';
import 'package:azkark/features/splash/splash_gate.dart';
import 'package:azkark/providers/sections_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_overlay/easy_overlay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'core/res/theme/theme.dart';

import 'localization/app_localizations_delegate.dart';

BuildContext? appContext;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    Provider.of<ThemeHelper>(context,listen: false).getCurrentTheme();
    // فُتح التطبيق من إشعار الأذان (فوق شاشة القفل)؟ نعرض شاشة الأذان
    WidgetsBinding.instance
        .addPostFrameCallback((_) => AzanAlarm.handleLaunch());
    // getIt<SettingViewModel>().getCurrentTheme();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.watch<ThemeHelper>().isDarkMode;
    appContext = context;
    // شيفرة بلا سياق (تحويل الأرقام) تقرأ اللغة من هنا
    AppLang.code = context.locale.languageCode;
    // ترجمة محتوى قاعدة الأذكار تتبع اللغة كذلك (لا تفعل شيئًا إن لم تتغيّر)
    DbTranslations.load(context.locale.languageCode);

    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      color:Theme.of(context).scaffoldBackgroundColor,


      //
      // debugShowCheckedModeBanner: false,
      // localizationsDelegates: const [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      // ],
      // supportedLocales: AppLocalizations.supportedLocales,
      // title: 'Quran',
      // theme: AppTheme().defaultTheme(),
      // onGenerateRoute: RouteGenerator.generateRoute,
      // home: AppStartupPage(),


      // localizationsDelegates: const [
      //   AppLocalizationsDelegate(),
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      // ],
      // supportedLocales: AppLocalizationsDelegate.supportedLocales(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      localeResolutionCallback: AppLocalizationsDelegate.resolution,


      // theme: AppTheme.appTheme(context),



      navigatorKey: AzanAlarm.navigatorKey,
      title: 'app_name'.tr(),
      debugShowCheckedModeBanner: false,
      builder: EasyOverlay.init(),
      home: Directionality(
        // الاتجاه يتبع اللغة: العربية RTL وبقية اللغات LTR. كان مثبتًا على
        // RTL فكانت الإنجليزية والفرنسية والألمانية تُرسم معكوسة.
        textDirection: context.locale.languageCode == 'ar'
            ? ui.TextDirection.rtl
            : ui.TextDirection.ltr,
        // شاشة البداية طبقة فوق المحتوى: هذا يُبنى خلفها من الإطار الأول
        // لا انتظار لتهيئة المصحف هنا: الرئيسية لا تحتاجها، وشاشة المصحف
        // تنتظرها بنفسها (quran_init.dart). ما يحجب الرئيسية الآن هو بيانات
        // الأقسام وحدها، وتُقرأ من القاعدة بالتوازي.
        child: SplashGate(
          child: Builder(
            builder: (context) => FutureBuilder<bool>(
              // المستقبل مخزّن داخل المزوّد فلا يُعاد إطلاقه مع كل بناء
              future: Provider.of<SectionsProvider>(context, listen: false)
                  .tryToGetData(context),
              builder: (context, result) =>
                  result.connectionState == ConnectionState.done
                      ? const HomePage()
                      : LoadingPage(),
            ),
          ),
        ),
      ),
    );
  }
}
