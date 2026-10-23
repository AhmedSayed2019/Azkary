import 'package:azkark/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import '../models/section_model.dart';
import 'asmaallah_provider.dart';
import 'categories_provider.dart';
import 'favorites_provider.dart';
import 'prayer_provider.dart';
import 'sebha_provider.dart';

class SectionsProvider with ChangeNotifier {
  List<SectionModel> _sections =[];
  DatabaseHelper databaseHelper = new DatabaseHelper();
  Future<bool>? _dataInitialization;

  String get table => 'sections';

  int get length => _sections.length;

  SectionModel getSection(int index) {
    return _sections[index];
  }

  List<int> getCategoriesIndex(int id) {
    return _sections[id].categoriesIndex;
  }

  Future<bool> initialAllSections() async {
    try {
      List<Map<String, dynamic>> tempSections =
          await databaseHelper.getData(table, '-1');
      print('tempSections.length : ${tempSections.length}');

      for (int i = 0; i < tempSections.length; i++)
        _sections.add(SectionModel.fromMap(tempSections[i]));

      print('_sections.length : ${_sections.length}');
      notifyListeners();
      return true;
    } catch (e) {
      print('Faild initialAllSections');
      print('e : $e');
      return false;
    }
  }

  Future<bool> tryToGetData(BuildContext context) async {
    return _dataInitialization ??= _loadData(context);
  }

  Future<bool> _loadData(BuildContext context) async {
    // كان هنا isFileExists() وهو يعني فعليًا "القاعدة مفتوحة مسبقًا": لو
    // فتحها أي كود آخر قبل هذه اللحظة لتخطّى التحميل كله وظهرت الرئيسية
    // بلا أقسام. البيانات في الذاكرة فقط، فتُحمَّل مرة في كل تشغيل دائمًا.
    // فتح القاعدة (ونسخها عند أول تثبيت) يسبق إطلاق الاستعلامات معًا.
    await databaseHelper.database;

    // كل مزوّد يقرأ جدوله الخاص فلا ترتيب بينها: تُطلق معًا بدل أن ينتظر
    // كل استعلام سابقه، والرئيسية محجوبة بشاشة التحميل حتى تنتهي كلها.
    // المزوّدات تُلتقط قبل أي await حتى لا يُستعمل السياق بعد فجوة غير متزامنة.
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final categories = Provider.of<CategoriesProvider>(context, listen: false);
    final sebha = Provider.of<SebhaProvider>(context, listen: false);
    final favorites = Provider.of<FavoritesProvider>(context, listen: false);
    final prayer = Provider.of<PrayerProvider>(context, listen: false);
    final asmaAllah = Provider.of<AsmaAllahProvider>(context, listen: false);
    try {
      await Future.wait([
        if (_sections.isEmpty) initialAllSections(),
        settings.initialSettings(),
        categories.initialAllCategories(),
        sebha.initialAllItemsOfSebha(),
        favorites.initialAllFavorites(),
        prayer.initialAllPrayer(),
        asmaAllah.initialAllAsmaAllah(),
      ]);
    } catch (e) {
      print('_initial e  : $e');
    }
    return true;
  }
}
