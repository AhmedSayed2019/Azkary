import 'dart:convert';

import 'package:azkark/core/extensions/num_extensions.dart';
import 'package:azkark/core/utils/constants.dart';
import 'package:azkark/features/QuranPages/bloc/player_bar_bloc.dart';
import 'package:azkark/features/audiopage/models/reciter.dart';
import 'package:azkark/features/audiopage/views/widgets/audio_cart_item_names.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';

import '../../../../core/utils/hive_helper.dart';
import '../../../QuranPages/bloc/player_bloc_bloc.dart';
import '../../../QuranPages/bloc/quran_page_player_bloc.dart';

final qurapPagePlayerBloc = QuranPagePlayerBloc();
final playerPageBloc = PlayerBlocBloc();
final playerbarBloc = PlayerBarBloc();

class AudioCartItem extends StatefulWidget {
  final Reciter _reciter;
  final List<Reciter> _favoriteRecitersList;
  final List _suwar;

  @override
  State<AudioCartItem> createState() => _AudioCartItemState();

  const AudioCartItem({
    required Reciter reciter,
    required List<Reciter> favoriteRecitersList,
    required List suwar,
  })  : _reciter = reciter,
        _favoriteRecitersList = favoriteRecitersList,
        _suwar = suwar;
}

class _AudioCartItemState extends State<AudioCartItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 15.0.w),
      child: Card(
        elevation: .8,
        color:getValue("darkMode")?darkModeSecondaryColor.withOpacity(.9): Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),

              Padding(
                padding: EdgeInsets.only(left: 14.0.w, right: 14.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget._reciter.name.toString(),
                      style: TextStyle(fontSize: 14.sp,color: getValue("darkMode")?Colors.white:Colors.black, fontWeight: FontWeight.bold, fontFamily: 'cairo'),
                    ),
                    IconButton(
                        onPressed: () {
                          if ( widget._favoriteRecitersList.contains( widget._reciter)) {
                            print("removing favorites");
                            widget._favoriteRecitersList.remove( widget._reciter);
                            updateValue("favoriteRecitersList", json.encode( widget._favoriteRecitersList));
                          } else {
                            print("adding favorites");
                            widget._favoriteRecitersList.add( widget._reciter);
                            updateValue("favoriteRecitersList", json.encode(widget._favoriteRecitersList));
                          }
                          setState(() {});
                        },
                        icon: Icon(
                          size: 20,
                          widget._favoriteRecitersList.contains( widget._reciter) ? FontAwesome.heart : FontAwesome.heart_empty,
                          color: Colors.redAccent.withOpacity(.6),
                        )),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              // Text(
              //   'Letter: ${reciter.letter}',
              //   style: const TextStyle(fontSize: 16),
              // ),
              // Text(
              //   'ID: ${reciter.id}',
              //   style: const TextStyle(fontSize: 16),
              // ),

              // padding: EdgeInsets.all(8.0),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget._reciter.moshaf.map((e) => AudioCartItemNameAndActions(reciter: widget._reciter, moshaf: e, suwar: widget._suwar)).toList(),
              ),
              SizedBox(height: 8.h),

              // You can add more properties from the Reciter class here
              // For example:
              // Text('Other Property: ${reciter.otherProperty}'),
              // ...
            ],
          ),
        ),
      ),
    );
  }
}
