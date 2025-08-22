import 'dart:convert';
import 'dart:developer';

import 'package:azkark/app.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';




class GetDataProvider extends ChangeNotifier{

  var widgejsonData;
  var quarterjsonData;
  Future initialQuranPages(BuildContext context) async {
      getAndStoreRadioData(context);
     checkSalahNotification();
     downloadAndStoreHadithData(context);

     getAndStoreRecitersData(context);

     loadJsonAsset();
    updateValue("timesOfAppOpen", getValue("timesOfAppOpen") + 1);
  }

  getAndStoreRadioData(BuildContext context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  Response response;

  try {
    if (appContext!.locale.languageCode == "ms") {
      response =
      await Dio().get('http://mp3quran.net/api/v3/radios?language=eng');
    } else {
      response = await Dio().get('http://mp3quran.net/api/v3/radios?language=${appContext!.locale.languageCode == "en" ? "eng" : appContext!.locale.languageCode}');
    }
    if (response.data != null) {
      final jsonData = json.encode(response.data['radios']);
      prefs.setString("radios-${appContext!.locale.languageCode == "en" ? "eng" : appContext!.locale.languageCode}", jsonData);
    }
  } catch (error) {
    print('Error while storing data: $error');
  }
}


Future<void> loadJsonAsset() async {
  final String jsonString =
  await rootBundle.loadString('assets/json/surahs.json');
  var data = jsonDecode(jsonString);
  widgejsonData = data;
  notifyListeners();
  log('loadJsonAsset:: ${widgejsonData}');

  final String jsonString2 = await rootBundle.loadString('assets/json/quarters.json');
  var data2 = jsonDecode(jsonString2);
  quarterjsonData = data2;
  notifyListeners();

  //print(widgejsonData);
}
  getAndStoreRecitersData(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("working");
    Response response;
    Response response2;
    Response response3;
    try {
      if (appContext!.locale.languageCode == "ms") {
        response =
        await Dio().get('http://mp3quran.net/api/v3/reciters?language=eng');
        response2 =
        await Dio().get('http://mp3quran.net/api/v3/moshaf?language=eng');
        response3 =
        await Dio().get('http://mp3quran.net/api/v3/suwar?language=eng');
      } else {
        response = await Dio().get(
            'http://mp3quran.net/api/v3/reciters?language=${appContext!.locale.languageCode == "en" ? "eng" : appContext!.locale.languageCode}');
        response2 = await Dio().get(
            'http://mp3quran.net/api/v3/moshaf?language=${appContext!.locale.languageCode == "en" ? "eng" : appContext!.locale.languageCode}');
        response3 = await Dio().get(
            'http://mp3quran.net/api/v3/suwar?language=${appContext!.locale.languageCode == "en" ? "eng" : appContext!.locale.languageCode}');
      }

      if (response.data != null) {
        final jsonData = json.encode(response.data['reciters']);
        prefs.setString(
            "reciters-${appContext!.locale.languageCode == "en" ? "eng" : appContext!.locale.languageCode}",
            jsonData);
      }
      if (response2.data != null) {
        final jsonData2 = json.encode(response2.data);
        prefs.setString(
            "moshaf-${appContext!.locale.languageCode == "en" ? "eng" : appContext!.locale.languageCode}",
            jsonData2);
      }
      if (response3.data != null) {
        final jsonData3 = json.encode(response3.data['suwar']);
        prefs.setString(
            "suwar-${appContext!.locale.languageCode == "en" ? "eng" : appContext!.locale.languageCode}",
            jsonData3);
      }
      print("worked");
    } catch (error) {
      print('Error while storing data: $error');
    }

    prefs.setInt("zikrNotificationindex", 0);
  }


  downloadAndStoreHadithData(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("hadithlist-100000-${appContext!.locale.languageCode}") ==
        null) {
      Response response = await Dio().get(
          "https://hadeethenc.com/api/v1/categories/roots/?language=${appContext!.locale.languageCode}");

      if (response.data != null) {
        final jsonData = json.encode(response.data);
        prefs.setString("categories-${appContext!.locale.languageCode}", jsonData);

        response.data.forEach((category) async {
          Response response2 = await Dio().get(
              "https://hadeethenc.com/api/v1/hadeeths/list/?language=${appContext!.locale.languageCode}&category_id=${category["id"]}&per_page=699999");

          if (response2.data != null) {
            final jsonData = json.encode(response2.data["data"]);
            prefs.setString(
                "hadithlist-${category["id"]}-${appContext!.locale.languageCode}",
                jsonData);

            ///add to category of all hadithlist
            if (prefs.getString(
                "hadithlist-100000-${appContext!.locale.languageCode}") ==
                null) {
              prefs.setString(
                  "hadithlist-100000-${appContext!.locale.languageCode}", jsonData);
            } else {
              final dataOfOldHadithlist = json.decode(prefs.getString(
                  "hadithlist-100000-${appContext!.locale.languageCode}")!)
              as List<dynamic>;
              dataOfOldHadithlist.addAll(json.decode(jsonData));
              prefs.setString(
                  "hadithlist-100000-${appContext!.locale.languageCode}",
                  json.encode(dataOfOldHadithlist));
            }
          }
        });
      }
    }

    //  if (response.data != null) {
    //       final jsonData = json.encode(response.data['reciters']);
    //       prefs.setString(
    //           "reciters-${appContext!.locale.languageCode == "en" ? "eng" : appContext!.locale.languageCode}",
    //           jsonData);
    //     }
  }

  checkSalahNotification() {
    if (getValue("shouldShowSallyNotification") == true) {
      Workmanager().registerOneOffTask("sallahEnable", "sallahEnable");
    } else {
      Workmanager().registerOneOffTask("sallahDisable", "sallahDisable");
    }
  }


}