import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/res/resources.dart';
import 'package:azkark/core/utils/constants.dart';
import 'package:azkark/features/QuranPages/bloc/player_bar_bloc.dart';
import 'package:azkark/features/audiopage/models/reciter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/hive_helper.dart';
import '../../../../generated/assets.dart';
import '../../../QuranPages/bloc/player_bloc_bloc.dart';
import '../../../QuranPages/bloc/quran_page_player_bloc.dart';
import '../reciter_all_surahs_page.dart';

final qurapPagePlayerBloc = QuranPagePlayerBloc();
final playerPageBloc = PlayerBlocBloc();
final playerbarBloc = PlayerBarBloc();

class AudioCartItemNameAndActions extends StatelessWidget {
  final Reciter _reciter;
  final Moshaf _moshaf;
  final List _suwar;
  const AudioCartItemNameAndActions({super.key,
    required Reciter reciter,
    required Moshaf moshaf,
    required List suwar,
  })  : _reciter = reciter,
        _moshaf = moshaf,
        _suwar = suwar;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder:
                        (builder) =>
                        BlocProvider(
                          create: (context) =>
                          playerPageBloc,
                          child:
                          RecitersSurahListPage(
                            reciter: _reciter,
                            mushaf: _moshaf,
                            jsonData: _suwar,
                          ),
                        )));
          },
          child: Column(
            children: [
              Divider(
                  height: 8.h),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(   child:Row(
                    children: [
                      SizedBox(width: 10.w),
                      Image(height: 15.h, image: const AssetImage(Assets.quranReading,)),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: SizedBox(
                          width: (deviceWidth * .5).w,
                          child: Text(_moshaf.name, overflow: TextOverflow.ellipsis, style: TextStyle(color: getValue("darkMode")?Colors.white.withOpacity(.87):Colors.black87, fontSize: 12.sp, fontFamily: 'cairo'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                  SizedBox(
                    child: BlocProvider(
                      create: (context) => PlayerBlocBloc(),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () async {
                                if (qurapPagePlayerBloc.state
                                is QuranPagePlayerPlaying) {
                                  await showDialog(
                                      context: context,
                                      builder: (a) {
                                        return AlertDialog(
                                          content: Text("closeplayer".tr()),
                                          actions: [
                                            TextButton(onPressed: () {Navigator.pop(context);}, child: Text("cancel".tr())),
                                            TextButton(onPressed: () {qurapPagePlayerBloc.add(KillPlayerEvent());Navigator.pop(context);}, child: Text("close".tr())),
                                          ],
                                        );
                                      });
                                }
                                playerPageBloc.add(StartPlaying(initialIndex: 0, moshaf: _moshaf, buildContext: context, reciter: _reciter, suraNumber: -1, jsonData: _suwar));
                              },
                              icon: Icon(size: 20.sp, Icons.play_circle_outline, color: orangeColor)
                          ),
                          IconButton(
                              onPressed: () {playerPageBloc.add(DownloadAllSurahs(moshaf: _moshaf, reciter: _reciter));},
                              icon: Icon(size: 20.sp, Icons.download, color: blueColor,)
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


}
