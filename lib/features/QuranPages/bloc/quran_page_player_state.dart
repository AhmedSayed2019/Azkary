part of 'quran_page_player_bloc.dart';

@immutable
class QuranPagePlayerState {}

class QuranPagePlayerInitial extends QuranPagePlayerState {}

class QuranPagePlayerPlaying extends QuranPagePlayerState {
  final Stream<Duration?> audioPlayerStream;
  final AudioPlayer player;
  final int suraNumber;
  final int verseNumber;
  final String reciterIdentifier;
  final List durations;
  final Map<String, dynamic> reciter;

  QuranPagePlayerPlaying({
    required this.player,
    required this.audioPlayerStream,
    required this.suraNumber,
    required this.verseNumber,
    required this.reciterIdentifier,
    required this.durations,
    required this.reciter,
  });
}

class QuranPagePlayerStopped extends QuranPagePlayerState {}

class QuranPagePlayerIdle extends QuranPagePlayerState {}