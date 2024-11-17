import 'dart:convert';

import 'package:azkark/data/models/surah_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../generated/assets.dart';

int bookmarkedAyah = 1;
int bookmarkedSura = 1;
bool fabIsClicked = true;

final ItemScrollController itemScrollController = ItemScrollController();
final ItemPositionsListener itemPositionsListener =ItemPositionsListener.create();


String arabicFont = 'quran';
double arabicFontSize = 28;
double mushafFontSize = 40;




saveBookMark (surah,ayah)async{
  final prefs=await SharedPreferences.getInstance();
  await prefs.setInt("surah", surah);
  await prefs.setInt("ayah", ayah);
}

readBookmark() async {
  print("read book mark called");
  final prefs = await SharedPreferences.getInstance();
  try {
    bookmarkedAyah = prefs.getInt('ayah')!;
    bookmarkedSura = prefs.getInt('surah')!;
    return true;
  } catch (e) {
    return false;
  }
}

getSurahImage(int index){
  return 'assets/images/surah/sname_${index+1}.png';
}


List<String> quranImages = [];

buildQuranImagesList({int? fromIndex , int? toIndex}){
  quranImages=[];
  for(int index=(fromIndex??1);index<=(toIndex??604);index++){
   String name =  _getQuranImageName(index);
    print('add iamge $name');
    quranImages.add(name);
  }
}


_getQuranImageName(int index)=>'assets/images/quran/${index}.png';


///old pages
_getOldQuranImageName(int index){
  String name = '';
  if(index<10){
    name = '00${index}';
  }else if(index<100){
    name = '0${index}';

  }else{
    name = '${index}';

  }
  return 'assets/images/quran/${name}_0.png';
}



//
// <{} 'assets/images/quran/001_0.png';
// <{} 'assets/images/quran/002_0.png';
// <{} 'assets/images/quran/003_0.png';
// <{} 'assets/images/quran/004_0.png';
// <{} 'assets/images/quran/005_0.png';
// <{} 'assets/images/quran/006_0.png';
// <{} 'assets/images/quran/007_0.png';
// <{} 'assets/images/quran/008_0.png';
// <{} 'assets/images/quran/009_0.png';
// <{} 'assets/images/quran/010_0.png';
// <{} 'assets/images/quran/011_0.png';
// <{} 'assets/images/quran/012_0.png';
// <{} 'assets/images/quran/013_0.png';
// <{} 'assets/images/quran/014_0.png';
// <{} 'assets/images/quran/015_0.png';
// <{} 'assets/images/quran/016_0.png';
// <{} 'assets/images/quran/017_0.png';
// <{} 'assets/images/quran/018_0.png';
// <{} 'assets/images/quran/019_0.png';
// <{} 'assets/images/quran/020_0.png';
// <{} 'assets/images/quran/021_0.png';
// <{} 'assets/images/quran/022_0.png';
// <{} 'assets/images/quran/023_0.png';
// <{} 'assets/images/quran/024_0.png';
// <{} 'assets/images/quran/025_0.png';
// <{} 'assets/images/quran/026_0.png';
// <{} 'assets/images/quran/027_0.png';
// <{} 'assets/images/quran/028_0.png';
// <{} 'assets/images/quran/029_0.png';
// <{} 'assets/images/quran/030_0.png';
// <{} 'assets/images/quran/031_0.png';
// <{} 'assets/images/quran/032_0.png';
// <{} 'assets/images/quran/033_0.png';
// <{} 'assets/images/quran/034_0.png';
// <{} 'assets/images/quran/035_0.png';
// <{} 'assets/images/quran/036_0.png';
// <{} 'assets/images/quran/037_0.png';
// <{} 'assets/images/quran/038_0.png';
// <{} 'assets/images/quran/039_0.png';
// <{} 'assets/images/quran/040_0.png';
// <{} 'assets/images/quran/041_0.png';
// <{} 'assets/images/quran/042_0.png';
// <{} 'assets/images/quran/043_0.png';
// <{} 'assets/images/quran/044_0.png';
// <{} 'assets/images/quran/045_0.png';
// <{} 'assets/images/quran/046_0.png';
// <{} 'assets/images/quran/047_0.png';
// <{} 'assets/images/quran/048_0.png';
// <{} 'assets/images/quran/049_0.png';
// <{} 'assets/images/quran/050_0.png';
// <{} 'assets/images/quran/051_0.png';
// <{} 'assets/images/quran/052_0.png';
// <{} 'assets/images/quran/053_0.png';
// <{} 'assets/images/quran/054_0.png';
// <{} 'assets/images/quran/055_0.png';
// <{} 'assets/images/quran/056_0.png';
// <{} 'assets/images/quran/057_0.png';
// <{} 'assets/images/quran/058_0.png';
// <{} 'assets/images/quran/059_0.png';
// <{} 'assets/images/quran/060_0.png';
// <{} 'assets/images/quran/061_0.png';
// <{} 'assets/images/quran/062_0.png';
// <{} 'assets/images/quran/063_0.png';
// <{} 'assets/images/quran/064_0.png';
// <{} 'assets/images/quran/065_0.png';
// <{} 'assets/images/quran/066_0.png';
// <{} 'assets/images/quran/067_0.png';
// <{} 'assets/images/quran/068_0.png';
// <{} 'assets/images/quran/069_0.png';
// <{} 'assets/images/quran/070_0.png';
// <{} 'assets/images/quran/071_0.png';
// <{} 'assets/images/quran/072_0.png';
// <{} 'assets/images/quran/073_0.png';
// <{} 'assets/images/quran/074_0.png';
// <{} 'assets/images/quran/075_0.png';
// <{} 'assets/images/quran/076_0.png';
// <{} 'assets/images/quran/077_0.png';
// <{} 'assets/images/quran/078_0.png';
// <{} 'assets/images/quran/079_0.png';
// <{} 'assets/images/quran/080_0.png';
// <{} 'assets/images/quran/081_0.png';
// <{} 'assets/images/quran/082_0.png';
// <{} 'assets/images/quran/083_0.png';
// <{} 'assets/images/quran/084_0.png';
// <{} 'assets/images/quran/085_0.png';
// <{} 'assets/images/quran/086_0.png';
// <{} 'assets/images/quran/087_0.png';
// <{} 'assets/images/quran/088_0.png';
// <{} 'assets/images/quran/089_0.png';
// <{} 'assets/images/quran/090_0.png';
// <{} 'assets/images/quran/091_0.png';
// <{} 'assets/images/quran/092_0.png';
// <{} 'assets/images/quran/093_0.png';
// <{} 'assets/images/quran/094_0.png';
// <{} 'assets/images/quran/095_0.png';
// <{} 'assets/images/quran/096_0.png';
// <{} 'assets/images/quran/097_0.png';
// <{} 'assets/images/quran/098_0.png';
// <{} 'assets/images/quran/099_0.png';
// <{} 'assets/images/quran/100_0.png';
// <{} 'assets/images/quran/101_0.png';
// <{} 'assets/images/quran/102_0.png';
// <{} 'assets/images/quran/103_0.png';
// <{} 'assets/images/quran/104_0.png';
// <{} 'assets/images/quran/105_0.png';
// <{} 'assets/images/quran/106_0.png';
// <{} 'assets/images/quran/107_0.png';
// <{} 'assets/images/quran/108_0.png';
// <{} 'assets/images/quran/109_0.png';
// <{} 'assets/images/quran/110_0.png';
// <{} 'assets/images/quran/111_0.png';
// <{} 'assets/images/quran/112_0.png';
// <{} 'assets/images/quran/113_0.png';
// <{} 'assets/images/quran/114_0.png';
// <{} 'assets/images/quran/115_0.png';
// <{} 'assets/images/quran/116_0.png';
// <{} 'assets/images/quran/117_0.png';
// <{} 'assets/images/quran/118_0.png';
// <{} 'assets/images/quran/119_0.png';
// <{} 'assets/images/quran/120_0.png';
// <{} 'assets/images/quran/121_0.png';
// <{} 'assets/images/quran/122_0.png';
// <{} 'assets/images/quran/123_0.png';
// <{} 'assets/images/quran/124_0.png';
// <{} 'assets/images/quran/125_0.png';
// <{} 'assets/images/quran/126_0.png';
// <{} 'assets/images/quran/127_0.png';
// <{} 'assets/images/quran/128_0.png';
// <{} 'assets/images/quran/129_0.png';
// <{} 'assets/images/quran/130_0.png';
// <{} 'assets/images/quran/131_0.png';
// <{} 'assets/images/quran/132_0.png';
// <{} 'assets/images/quran/133_0.png';
// <{} 'assets/images/quran/134_0.png';
// <{} 'assets/images/quran/135_0.png';
// <{} 'assets/images/quran/136_0.png';
// <{} 'assets/images/quran/137_0.png';
// <{} 'assets/images/quran/138_0.png';
// <{} 'assets/images/quran/139_0.png';
// <{} 'assets/images/quran/140_0.png';
// <{} 'assets/images/quran/141_0.png';
// <{} 'assets/images/quran/142_0.png';
// <{} 'assets/images/quran/143_0.png';
// <{} 'assets/images/quran/144_0.png';
// <{} 'assets/images/quran/145_0.png';
// <{} 'assets/images/quran/146_0.png';
// <{} 'assets/images/quran/147_0.png';
// <{} 'assets/images/quran/148_0.png';
// <{} 'assets/images/quran/149_0.png';
// <{} 'assets/images/quran/150_0.png';
// <{} 'assets/images/quran/151_0.png';
// <{} 'assets/images/quran/152_0.png';
// <{} 'assets/images/quran/153_0.png';
// <{} 'assets/images/quran/154_0.png';
// <{} 'assets/images/quran/155_0.png';
// <{} 'assets/images/quran/156_0.png';
// <{} 'assets/images/quran/157_0.png';
// <{} 'assets/images/quran/158_0.png';
// <{} 'assets/images/quran/159_0.png';
// <{} 'assets/images/quran/160_0.png';
// <{} 'assets/images/quran/161_0.png';
// <{} 'assets/images/quran/162_0.png';
// <{} 'assets/images/quran/163_0.png';
// <{} 'assets/images/quran/164_0.png';
// <{} 'assets/images/quran/165_0.png';
// <{} 'assets/images/quran/166_0.png';
// <{} 'assets/images/quran/167_0.png';
// <{} 'assets/images/quran/168_0.png';
// <{} 'assets/images/quran/169_0.png';
// <{} 'assets/images/quran/170_0.png';
// <{} 'assets/images/quran/171_0.png';
// <{} 'assets/images/quran/172_0.png';
// <{} 'assets/images/quran/173_0.png';
// <{} 'assets/images/quran/174_0.png';
// <{} 'assets/images/quran/175_0.png';
// <{} 'assets/images/quran/176_0.png';
// <{} 'assets/images/quran/177_0.png';
// <{} 'assets/images/quran/178_0.png';
// <{} 'assets/images/quran/179_0.png';
// <{} 'assets/images/quran/180_0.png';
// <{} 'assets/images/quran/181_0.png';
// <{} 'assets/images/quran/182_0.png';
// <{} 'assets/images/quran/183_0.png';
// <{} 'assets/images/quran/184_0.png';
// <{} 'assets/images/quran/185_0.png';
// <{} 'assets/images/quran/186_0.png';
// <{} 'assets/images/quran/187_0.png';
// <{} 'assets/images/quran/188_0.png';
// <{} 'assets/images/quran/189_0.png';
// <{} 'assets/images/quran/190_0.png';
// <{} 'assets/images/quran/191_0.png';
// <{} 'assets/images/quran/192_0.png';
// <{} 'assets/images/quran/193_0.png';
// <{} 'assets/images/quran/194_0.png';
// <{} 'assets/images/quran/195_0.png';
// <{} 'assets/images/quran/196_0.png';
// <{} 'assets/images/quran/197_0.png';
// <{} 'assets/images/quran/198_0.png';
// <{} 'assets/images/quran/199_0.png';
// <{} 'assets/images/quran/200_0.png';
// <{} 'assets/images/quran/201_0.png';
// <{} 'assets/images/quran/202_0.png';
// <{} 'assets/images/quran/203_0.png';
// <{} 'assets/images/quran/204_0.png';
// <{} 'assets/images/quran/205_0.png';
// <{} 'assets/images/quran/206_0.png';
// <{} 'assets/images/quran/207_0.png';
// <{} 'assets/images/quran/208_0.png';
// <{} 'assets/images/quran/209_0.png';
// <{} 'assets/images/quran/210_0.png';
// <{} 'assets/images/quran/211_0.png';
// <{} 'assets/images/quran/212_0.png';
// <{} 'assets/images/quran/213_0.png';
// <{} 'assets/images/quran/214_0.png';
// <{} 'assets/images/quran/215_0.png';
// <{} 'assets/images/quran/216_0.png';
// <{} 'assets/images/quran/217_0.png';
// <{} 'assets/images/quran/218_0.png';
// <{} 'assets/images/quran/219_0.png';
// <{} 'assets/images/quran/220_0.png';
// <{} 'assets/images/quran/221_0.png';
// <{} 'assets/images/quran/222_0.png';
// <{} 'assets/images/quran/223_0.png';
// <{} 'assets/images/quran/224_0.png';
// <{} 'assets/images/quran/225_0.png';
// <{} 'assets/images/quran/226_0.png';
// <{} 'assets/images/quran/227_0.png';
// <{} 'assets/images/quran/228_0.png';
// <{} 'assets/images/quran/229_0.png';
// <{} 'assets/images/quran/230_0.png';
// <{} 'assets/images/quran/231_0.png';
// <{} 'assets/images/quran/232_0.png';
// <{} 'assets/images/quran/233_0.png';
// <{} 'assets/images/quran/234_0.png';
// <{} 'assets/images/quran/235_0.png';
// <{} 'assets/images/quran/236_0.png';
// <{} 'assets/images/quran/237_0.png';
// <{} 'assets/images/quran/238_0.png';
// <{} 'assets/images/quran/239_0.png';
// <{} 'assets/images/quran/240_0.png';
// <{} 'assets/images/quran/241_0.png';
// <{} 'assets/images/quran/242_0.png';
// <{} 'assets/images/quran/243_0.png';
// <{} 'assets/images/quran/244_0.png';
// <{} 'assets/images/quran/245_0.png';
// <{} 'assets/images/quran/246_0.png';
// <{} 'assets/images/quran/247_0.png';
// <{} 'assets/images/quran/248_0.png';
// <{} 'assets/images/quran/249_0.png';
// <{} 'assets/images/quran/250_0.png';
// <{} 'assets/images/quran/251_0.png';
// <{} 'assets/images/quran/252_0.png';
// <{} 'assets/images/quran/253_0.png';
// <{} 'assets/images/quran/254_0.png';
// <{} 'assets/images/quran/255_0.png';
// <{} 'assets/images/quran/256_0.png';
// <{} 'assets/images/quran/257_0.png';
// <{} 'assets/images/quran/258_0.png';
// <{} 'assets/images/quran/259_0.png';
// <{} 'assets/images/quran/260_0.png';
// <{} 'assets/images/quran/261_0.png';
// <{} 'assets/images/quran/262_0.png';
// <{} 'assets/images/quran/263_0.png';
// <{} 'assets/images/quran/264_0.png';
// <{} 'assets/images/quran/265_0.png';
// <{} 'assets/images/quran/266_0.png';
// <{} 'assets/images/quran/267_0.png';
// <{} 'assets/images/quran/268_0.png';
// <{} 'assets/images/quran/269_0.png';
// <{} 'assets/images/quran/270_0.png';
// <{} 'assets/images/quran/271_0.png';
// <{} 'assets/images/quran/272_0.png';
// <{} 'assets/images/quran/273_0.png';
// <{} 'assets/images/quran/274_0.png';
// <{} 'assets/images/quran/275_0.png';
// <{} 'assets/images/quran/276_0.png';
// <{} 'assets/images/quran/277_0.png';
// <{} 'assets/images/quran/278_0.png';
// <{} 'assets/images/quran/279_0.png';
// <{} 'assets/images/quran/280_0.png';
// <{} 'assets/images/quran/281_0.png';
// <{} 'assets/images/quran/282_0.png';
// <{} 'assets/images/quran/283_0.png';
// <{} 'assets/images/quran/284_0.png';
// <{} 'assets/images/quran/285_0.png';
// <{} 'assets/images/quran/286_0.png';
// <{} 'assets/images/quran/287_0.png';
// <{} 'assets/images/quran/288_0.png';
// <{} 'assets/images/quran/289_0.png';
// <{} 'assets/images/quran/290_0.png';
// <{} 'assets/images/quran/291_0.png';
// <{} 'assets/images/quran/292_0.png';
// <{} 'assets/images/quran/293_0.png';
// <{} 'assets/images/quran/294_0.png';
// <{} 'assets/images/quran/295_0.png';
// <{} 'assets/images/quran/296_0.png';
// <{} 'assets/images/quran/297_0.png';
// <{} 'assets/images/quran/298_0.png';
// <{} 'assets/images/quran/299_0.png';
// <{} 'assets/images/quran/300_0.png';
// <{} 'assets/images/quran/301_0.png';
// <{} 'assets/images/quran/302_0.png';
// <{} 'assets/images/quran/303_0.png';
// <{} 'assets/images/quran/304_0.png';
// <{} 'assets/images/quran/305_0.png';
// <{} 'assets/images/quran/306_0.png';
// <{} 'assets/images/quran/307_0.png';
// <{} 'assets/images/quran/308_0.png';
// <{} 'assets/images/quran/309_0.png';
// <{} 'assets/images/quran/310_0.png';
// <{} 'assets/images/quran/311_0.png';
// <{} 'assets/images/quran/312_0.png';
// <{} 'assets/images/quran/313_0.png';
// <{} 'assets/images/quran/314_0.png';
// <{} 'assets/images/quran/315_0.png';
// <{} 'assets/images/quran/316_0.png';
// <{} 'assets/images/quran/317_0.png';
// <{} 'assets/images/quran/318_0.png';
// <{} 'assets/images/quran/319_0.png';
// <{} 'assets/images/quran/320_0.png';
// <{} 'assets/images/quran/321_0.png';
// <{} 'assets/images/quran/322_0.png';
// <{} 'assets/images/quran/323_0.png';
// <{} 'assets/images/quran/324_0.png';
// <{} 'assets/images/quran/325_0.png';
// <{} 'assets/images/quran/326_0.png';
// <{} 'assets/images/quran/327_0.png';
// <{} 'assets/images/quran/328_0.png';
// <{} 'assets/images/quran/329_0.png';
// <{} 'assets/images/quran/330_0.png';
// <{} 'assets/images/quran/331_0.png';
// <{} 'assets/images/quran/332_0.png';
// <{} 'assets/images/quran/333_0.png';
// <{} 'assets/images/quran/334_0.png';
// <{} 'assets/images/quran/335_0.png';
// <{} 'assets/images/quran/336_0.png';
// <{} 'assets/images/quran/337_0.png';
// <{} 'assets/images/quran/338_0.png';
// <{} 'assets/images/quran/339_0.png';
// <{} 'assets/images/quran/340_0.png';
// <{} 'assets/images/quran/341_0.png';
// <{} 'assets/images/quran/342_0.png';
// <{} 'assets/images/quran/343_0.png';
// <{} 'assets/images/quran/344_0.png';
// <{} 'assets/images/quran/345_0.png';
// <{} 'assets/images/quran/346_0.png';
// <{} 'assets/images/quran/347_0.png';
// <{} 'assets/images/quran/348_0.png';
// <{} 'assets/images/quran/349_0.png';
// <{} 'assets/images/quran/350_0.png';
// <{} 'assets/images/quran/351_0.png';
// <{} 'assets/images/quran/352_0.png';
// <{} 'assets/images/quran/353_0.png';
// <{} 'assets/images/quran/354_0.png';
// <{} 'assets/images/quran/355_0.png';
// <{} 'assets/images/quran/356_0.png';
// <{} 'assets/images/quran/357_0.png';
// <{} 'assets/images/quran/358_0.png';
// <{} 'assets/images/quran/359_0.png';
// <{} 'assets/images/quran/360_0.png';
// <{} 'assets/images/quran/361_0.png';
// <{} 'assets/images/quran/362_0.png';
// <{} 'assets/images/quran/363_0.png';
// <{} 'assets/images/quran/364_0.png';
// <{} 'assets/images/quran/365_0.png';
// <{} 'assets/images/quran/366_0.png';
// <{} 'assets/images/quran/367_0.png';
// <{} 'assets/images/quran/368_0.png';
// <{} 'assets/images/quran/369_0.png';
// <{} 'assets/images/quran/370_0.png';
// <{} 'assets/images/quran/371_0.png';
// <{} 'assets/images/quran/372_0.png';
// <{} 'assets/images/quran/373_0.png';
// <{} 'assets/images/quran/374_0.png';
// <{} 'assets/images/quran/375_0.png';
// <{} 'assets/images/quran/376_0.png';
// <{} 'assets/images/quran/377_0.png';
// <{} 'assets/images/quran/378_0.png';
// <{} 'assets/images/quran/379_0.png';
// <{} 'assets/images/quran/380_0.png';
// <{} 'assets/images/quran/381_0.png';
// <{} 'assets/images/quran/382_0.png';
// <{} 'assets/images/quran/383_0.png';
// <{} 'assets/images/quran/384_0.png';
// <{} 'assets/images/quran/385_0.png';
// <{} 'assets/images/quran/386_0.png';
// <{} 'assets/images/quran/387_0.png';
// <{} 'assets/images/quran/388_0.png';
// <{} 'assets/images/quran/389_0.png';
// <{} 'assets/images/quran/390_0.png';
// <{} 'assets/images/quran/391_0.png';
// <{} 'assets/images/quran/392_0.png';
// <{} 'assets/images/quran/393_0.png';
// <{} 'assets/images/quran/394_0.png';
// <{} 'assets/images/quran/395_0.png';
// <{} 'assets/images/quran/396_0.png';
// <{} 'assets/images/quran/397_0.png';
// <{} 'assets/images/quran/398_0.png';
// <{} 'assets/images/quran/399_0.png';
// <{} 'assets/images/quran/400_0.png';
// <{} 'assets/images/quran/401_0.png';
// <{} 'assets/images/quran/402_0.png';
// <{} 'assets/images/quran/403_0.png';
// <{} 'assets/images/quran/404_0.png';
// <{} 'assets/images/quran/405_0.png';
// <{} 'assets/images/quran/406_0.png';
// <{} 'assets/images/quran/407_0.png';
// <{} 'assets/images/quran/408_0.png';
// <{} 'assets/images/quran/409_0.png';
// <{} 'assets/images/quran/410_0.png';
// <{} 'assets/images/quran/411_0.png';
// <{} 'assets/images/quran/412_0.png';
// <{} 'assets/images/quran/413_0.png';
// <{} 'assets/images/quran/414_0.png';
// <{} 'assets/images/quran/415_0.png';
// <{} 'assets/images/quran/416_0.png';
// <{} 'assets/images/quran/417_0.png';
// <{} 'assets/images/quran/418_0.png';
// <{} 'assets/images/quran/419_0.png';
// <{} 'assets/images/quran/420_0.png';
// <{} 'assets/images/quran/421_0.png';
// <{} 'assets/images/quran/422_0.png';
// <{} 'assets/images/quran/423_0.png';
// <{} 'assets/images/quran/424_0.png';
// <{} 'assets/images/quran/425_0.png';
// <{} 'assets/images/quran/426_0.png';
// <{} 'assets/images/quran/427_0.png';
// <{} 'assets/images/quran/428_0.png';
// <{} 'assets/images/quran/429_0.png';
// <{} 'assets/images/quran/430_0.png';
// <{} 'assets/images/quran/431_0.png';
// <{} 'assets/images/quran/432_0.png';
// <{} 'assets/images/quran/433_0.png';
// <{} 'assets/images/quran/434_0.png';
// <{} 'assets/images/quran/435_0.png';
// <{} 'assets/images/quran/436_0.png';
// <{} 'assets/images/quran/437_0.png';
// <{} 'assets/images/quran/438_0.png';
// <{} 'assets/images/quran/439_0.png';
// <{} 'assets/images/quran/440_0.png';
// <{} 'assets/images/quran/441_0.png';
// <{} 'assets/images/quran/442_0.png';
// <{} 'assets/images/quran/443_0.png';
// <{} 'assets/images/quran/444_0.png';
// <{} 'assets/images/quran/445_0.png';
// <{} 'assets/images/quran/446_0.png';
// <{} 'assets/images/quran/447_0.png';
// <{} 'assets/images/quran/448_0.png';
// <{} 'assets/images/quran/449_0.png';
// <{} 'assets/images/quran/450_0.png';
// <{} 'assets/images/quran/451_0.png';
// <{} 'assets/images/quran/452_0.png';
// <{} 'assets/images/quran/453_0.png';
// <{} 'assets/images/quran/454_0.png';
// <{} 'assets/images/quran/455_0.png';
// <{} 'assets/images/quran/456_0.png';
// <{} 'assets/images/quran/457_0.png';
// <{} 'assets/images/quran/458_0.png';
// <{} 'assets/images/quran/459_0.png';
// <{} 'assets/images/quran/460_0.png';
// <{} 'assets/images/quran/461_0.png';
// <{} 'assets/images/quran/462_0.png';
// <{} 'assets/images/quran/463_0.png';
// <{} 'assets/images/quran/464_0.png';
// <{} 'assets/images/quran/465_0.png';
// <{} 'assets/images/quran/466_0.png';
// <{} 'assets/images/quran/467_0.png';
// <{} 'assets/images/quran/468_0.png';
// <{} 'assets/images/quran/469_0.png';
// <{} 'assets/images/quran/470_0.png';
// <{} 'assets/images/quran/471_0.png';
// <{} 'assets/images/quran/472_0.png';
// <{} 'assets/images/quran/473_0.png';
// <{} 'assets/images/quran/474_0.png';
// <{} 'assets/images/quran/475_0.png';
// <{} 'assets/images/quran/476_0.png';
// <{} 'assets/images/quran/477_0.png';
// <{} 'assets/images/quran/478_0.png';
// <{} 'assets/images/quran/479_0.png';
// <{} 'assets/images/quran/480_0.png';
// <{} 'assets/images/quran/481_0.png';
// <{} 'assets/images/quran/482_0.png';
// <{} 'assets/images/quran/483_0.png';
// <{} 'assets/images/quran/484_0.png';
// <{} 'assets/images/quran/485_0.png';
// <{} 'assets/images/quran/486_0.png';
// <{} 'assets/images/quran/487_0.png';
// <{} 'assets/images/quran/488_0.png';
// <{} 'assets/images/quran/489_0.png';
// <{} 'assets/images/quran/490_0.png';
// <{} 'assets/images/quran/491_0.png';
// <{} 'assets/images/quran/492_0.png';
// <{} 'assets/images/quran/493_0.png';
// <{} 'assets/images/quran/494_0.png';
// <{} 'assets/images/quran/495_0.png';
// <{} 'assets/images/quran/496_0.png';
// <{} 'assets/images/quran/497_0.png';
// <{} 'assets/images/quran/498_0.png';
// <{} 'assets/images/quran/499_0.png';
// <{} 'assets/images/quran/500_0.png';
// <{} 'assets/images/quran/501_0.png';
// <{} 'assets/images/quran/502_0.png';
// <{} 'assets/images/quran/503_0.png';
// <{} 'assets/images/quran/504_0.png';
// <{} 'assets/images/quran/505_0.png';
// <{} 'assets/images/quran/506_0.png';
// <{} 'assets/images/quran/507_0.png';
// <{} 'assets/images/quran/508_0.png';
// <{} 'assets/images/quran/509_0.png';
// <{} 'assets/images/quran/510_0.png';
// <{} 'assets/images/quran/511_0.png';
// <{} 'assets/images/quran/512_0.png';
// <{} 'assets/images/quran/513_0.png';
// <{} 'assets/images/quran/514_0.png';
// <{} 'assets/images/quran/515_0.png';
// <{} 'assets/images/quran/516_0.png';
// <{} 'assets/images/quran/517_0.png';
// <{} 'assets/images/quran/518_0.png';
// <{} 'assets/images/quran/519_0.png';
// <{} 'assets/images/quran/520_0.png';
// <{} 'assets/images/quran/521_0.png';
// <{} 'assets/images/quran/522_0.png';
// <{} 'assets/images/quran/523_0.png';
// <{} 'assets/images/quran/524_0.png';
// <{} 'assets/images/quran/525_0.png';
// <{} 'assets/images/quran/526_0.png';
// <{} 'assets/images/quran/527_0.png';
// <{} 'assets/images/quran/528_0.png';
// <{} 'assets/images/quran/529_0.png';
// <{} 'assets/images/quran/530_0.png';
// <{} 'assets/images/quran/531_0.png';
// <{} 'assets/images/quran/532_0.png';
// <{} 'assets/images/quran/533_0.png';
// <{} 'assets/images/quran/534_0.png';
// <{} 'assets/images/quran/535_0.png';
// <{} 'assets/images/quran/536_0.png';
// <{} 'assets/images/quran/537_0.png';
// <{} 'assets/images/quran/538_0.png';
// <{} 'assets/images/quran/539_0.png';
// <{} 'assets/images/quran/540_0.png';
// <{} 'assets/images/quran/541_0.png';
// <{} 'assets/images/quran/542_0.png';
// <{} 'assets/images/quran/543_0.png';
// <{} 'assets/images/quran/544_0.png';
// <{} 'assets/images/quran/545_0.png';
// <{} 'assets/images/quran/546_0.png';
// <{} 'assets/images/quran/547_0.png';
// <{} 'assets/images/quran/548_0.png';
// <{} 'assets/images/quran/549_0.png';
// <{} 'assets/images/quran/550_0.png';
// <{} 'assets/images/quran/551_0.png';
// <{} 'assets/images/quran/552_0.png';
// <{} 'assets/images/quran/553_0.png';
// <{} 'assets/images/quran/554_0.png';
// <{} 'assets/images/quran/555_0.png';
// <{} 'assets/images/quran/556_0.png';
// <{} 'assets/images/quran/557_0.png';
// <{} 'assets/images/quran/558_0.png';
// <{} 'assets/images/quran/559_0.png';
// <{} 'assets/images/quran/560_0.png';
// <{} 'assets/images/quran/561_0.png';
// <{} 'assets/images/quran/562_0.png';
// <{} 'assets/images/quran/563_0.png';
// <{} 'assets/images/quran/564_0.png';
// <{} 'assets/images/quran/565_0.png';
// <{} 'assets/images/quran/566_0.png';
// <{} 'assets/images/quran/567_0.png';
// <{} 'assets/images/quran/568_0.png';
// <{} 'assets/images/quran/569_0.png';
// <{} 'assets/images/quran/570_0.png';
// <{} 'assets/images/quran/571_0.png';
// <{} 'assets/images/quran/572_0.png';
// <{} 'assets/images/quran/573_0.png';
// <{} 'assets/images/quran/574_0.png';
// <{} 'assets/images/quran/575_0.png';
// <{} 'assets/images/quran/576_0.png';
// <{} 'assets/images/quran/577_0.png';
// <{} 'assets/images/quran/578_0.png';
// <{} 'assets/images/quran/579_0.png';
// <{} 'assets/images/quran/580_0.png';
// <{} 'assets/images/quran/581_0.png';
// <{} 'assets/images/quran/582_0.png';
// <{} 'assets/images/quran/583_0.png';
// <{} 'assets/images/quran/584_0.png';
// <{} 'assets/images/quran/585_0.png';
// <{} 'assets/images/quran/586_0.png';
// <{} 'assets/images/quran/587_0.png';
// <{} 'assets/images/quran/588_0.png';
// <{} 'assets/images/quran/589_0.png';
// <{} 'assets/images/quran/590_0.png';
// <{} 'assets/images/quran/591_0.png';
// <{} 'assets/images/quran/592_0.png';
// <{} 'assets/images/quran/593_0.png';
// <{} 'assets/images/quran/594_0.png';
// <{} 'assets/images/quran/595_0.png';
// <{} 'assets/images/quran/596_0.png';
// <{} 'assets/images/quran/597_0.png';
// <{} 'assets/images/quran/598_0.png';
// <{} 'assets/images/quran/599_0.png';
// <{} 'assets/images/quran/600_0.png';
// <{} 'assets/images/quran/601_0.png';
// <{} 'assets/images/quran/602_0.png';
// <{} 'assets/images/quran/603_0.png';
// <{} 'assets/images/quran/604_0.png';
List<Map> arabicName = [
  {"surah": "1", "name": "الفاتحة","ayaCounter":7,"startPage":1,},
  {"surah": "2", "name": "البقرة","ayaCounter":286,"startPage":2,},
  {"surah": "3", "name": "آل عمران","ayaCounter":286,"startPage":50,},
  {"surah": "4", "name": "النساء"},
  {"surah": "5", "name": "المائدة"},
  {"surah": "6", "name": "الأنعام"},
  {"surah": "7", "name": "الأعراف"},
  {"surah": "8", "name": "الأنفال"},
  {"surah": "9", "name": "التوبة"},
  {"surah": "10", "name": "يونس"},
  {"surah": "11", "name": "هود"},
  {"surah": "12", "name": "يوسف"},
  {"surah": "13", "name": "الرعد"},
  {"surah": "14", "name": "ابراهيم"},
  {"surah": "15", "name": "الحجر"},
  {"surah": "16", "name": "النحل"},
  {"surah": "17", "name": "الإسراء"},
  {"surah": "18", "name": "الكهف"},
  {"surah": "19", "name": "مريم"},
  {"surah": "20", "name": "طه"},
  {"surah": "21", "name": "الأنبياء"},
  {"surah": "22", "name": "الحج"},
  {"surah": "23", "name": "المؤمنون"},
  {"surah": "24", "name": "النور"},
  {"surah": "25", "name": "الفرقان"},
  {"surah": "26", "name": "الشعراء"},
  {"surah": "27", "name": "النمل"},
  {"surah": "28", "name": "القصص"},
  {"surah": "29", "name": "العنكبوت"},
  {"surah": "30", "name": "الروم"},
  {"surah": "31", "name": "لقمان"},
  {"surah": "32", "name": "السجدة"},
  {"surah": "33", "name": "الأحزاب"},
  {"surah": "34", "name": "سبإ"},
  {"surah": "35", "name": "فاطر"},
  {"surah": "36", "name": "يس"},
  {"surah": "37", "name": "الصافات"},
  {"surah": "38", "name": "ص"},
  {"surah": "39", "name": "الزمر"},
  {"surah": "40", "name": "غافر"},
  {"surah": "41", "name": "فصلت"},
  {"surah": "42", "name": "الشورى"},
  {"surah": "43", "name": "الزخرف"},
  {"surah": "44", "name": "الدخان"},
  {"surah": "45", "name": "الجاثية"},
  {"surah": "46", "name": "الأحقاف"},
  {"surah": "47", "name": "محمد"},
  {"surah": "48", "name": "الفتح"},
  {"surah": "49", "name": "الحجرات"},
  {"surah": "50", "name": "ق"},
  {"surah": "51", "name": "الذاريات"},
  {"surah": "52", "name": "الطور"},
  {"surah": "53", "name": "النجم"},
  {"surah": "54", "name": "القمر"},
  {"surah": "55", "name": "الرحمن"},
  {"surah": "56", "name": "الواقعة"},
  {"surah": "57", "name": "الحديد"},
  {"surah": "58", "name": "المجادلة"},
  {"surah": "59", "name": "الحشر"},
  {"surah": "60", "name": "الممتحنة"},
  {"surah": "61", "name": "الصف"},
  {"surah": "62", "name": "الجمعة"},
  {"surah": "63", "name": "المنافقون"},
  {"surah": "64", "name": "التغابن"},
  {"surah": "65", "name": "الطلاق"},
  {"surah": "66", "name": "التحريم"},
  {"surah": "67", "name": "الملك"},
  {"surah": "68", "name": "القلم"},
  {"surah": "69", "name": "الحاقة"},
  {"surah": "70", "name": "المعارج"},
  {"surah": "71", "name": "نوح"},
  {"surah": "72", "name": "الجن"},
  {"surah": "73", "name": "المزمل"},
  {"surah": "74", "name": "المدثر"},
  {"surah": "75", "name": "القيامة"},
  {"surah": "76", "name": "الانسان"},
  {"surah": "77", "name": "المرسلات"},
  {"surah": "78", "name": "النبإ"},
  {"surah": "79", "name": "النازعات"},
  {"surah": "80", "name": "عبس"},
  {"surah": "81", "name": "التكوير"},
  {"surah": "82", "name": "الإنفطار"},
  {"surah": "83", "name": "المطففين"},
  {"surah": "84", "name": "الإنشقاق"},
  {"surah": "85", "name": "البروج"},
  {"surah": "86", "name": "الطارق"},
  {"surah": "87", "name": "الأعلى"},
  {"surah": "88", "name": "الغاشية"},
  {"surah": "89", "name": "الفجر"},
  {"surah": "90", "name": "البلد"},
  {"surah": "91", "name": "الشمس"},
  {"surah": "92", "name": "الليل"},
  {"surah": "93", "name": "الضحى"},
  {"surah": "94", "name": "الشرح"},
  {"surah": "95", "name": "التين"},
  {"surah": "96", "name": "العلق"},
  {"surah": "97", "name": "القدر"},
  {"surah": "98", "name": "البينة"},
  {"surah": "99", "name": "الزلزلة"},
  {"surah": "100", "name": "العاديات"},
  {"surah": "101", "name": "القارعة"},
  {"surah": "102", "name": "التكاثر"},
  {"surah": "103", "name": "العصر"},
  {"surah": "104", "name": "الهمزة"},
  {"surah": "105", "name": "الفيل"},
  {"surah": "106", "name": "قريش"},
  {"surah": "107", "name": "الماعون"},
  {"surah": "108", "name": "الكوثر"},
  {"surah": "109", "name": "الكافرون"},
  {"surah": "110", "name": "النصر"},
  {"surah": "111", "name": "المسد"},
  {"surah": "112", "name": "الإخلاص"},
  {"surah": "113", "name": "الفلق"},
  {"surah": "114", "name": "الناس"}
];

List<int> noOfVerses = [
  7,
  286,
  200,
  176,
  120,
  165,
  206,
  75,
  129,
  109,
  123,
  111,
  43,
  52,
  99,
  128,
  111,
  110,
  98,
  135,
  112,
  78,
  118,
  64,
  77,
  227,
  93,
  88,
  69,
  60,
  34,
  30,
  73,
  54,
  45,
  83,
  182,
  88,
  75,
  85,
  54,
  53,
  89,
  59,
  37,
  35,
  38,
  29,
  18,
  45,
  60,
  49,
  62,
  55,
  78,
  96,
  29,
  22,
  24,
  13,
  14,
  11,
  11,
  18,
  12,
  12,
  30,
  52,
  52,
  44,
  28,
  28,
  20,
  56,
  40,
  31,
  50,
  40,
  46,
  42,
  29,
  19,
  36,
  25,
  22,
  17,
  19,
  26,
  30,
  20,
  15,
  21,
  11,

  8,
  8,
  19,
  5,
  8,
  8,
  11,
  11,
  8,
  3,
  9,
  5,
  4,
  7,
  3,
  6,
  3,
  5,
  4,
  5,
  6
];

// List arabic =[];
// List malayalam =[];
// List quran =[];
List<SurahModel> ayatElQuran=[];

Future<List<SurahModel>> readJson ()async{
  final String response =await rootBundle.loadString("assets/hafs_smart_v8.json");
  final data=json.decode(response);

  ayatElQuran = List<SurahModel>.from((data["quran"]??[]).map((x) => SurahModel.fromJson(x)));

  print('zzzzzzzzzzzz ${ayatElQuran.length}');
  // arabic=data["quran"];
  // malayalam=data["malayalam"];
  return ayatElQuran;//quran=[arabic,malayalam];
}