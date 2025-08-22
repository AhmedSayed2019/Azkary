import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:azkark/core/utils/audio_path_helper.dart';
import 'package:azkark/core/utils/hive_helper.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:quran/quran.dart' as quran;

class DownloadHelper extends ChangeNotifier {
  final _log = debugPrint;
  final statistics = ValueNotifier<String?>(null);
  final progress = ValueNotifier<double?>(null);
  bool isDownloading = false;

  Future<void> downloadAndCacheSuraAudio(String suraName, int totalVerses, int suraNumber, String reciterIdentifier) async {
    try {
      isDownloading = true;
      notifyListeners();

      final fullSuraFilePath = await AudioPathHelper.getSuraAudioPath(reciterIdentifier, suraName);
      _log('Full sura file path: $fullSuraFilePath');

      if (await _isFullSuraDownloaded(fullSuraFilePath)) {
        return;
      }

      Fluttertoast.showToast(msg: "Downloading...");
      final verseFiles = await _downloadVerseFiles(suraName, totalVerses, suraNumber, reciterIdentifier);
      
      if (verseFiles.isNotEmpty) {
        await _combineAudioFiles(verseFiles, fullSuraFilePath);
      }
    } catch (e) {
      _log('Error in downloadAndCacheSuraAudio: $e');
      Fluttertoast.showToast(msg: "Download failed");
    } finally {
      isDownloading = false;
      notifyListeners();
    }
  }

  Future<bool> _isFullSuraDownloaded(String fullSuraFilePath) async {
    if (File(fullSuraFilePath).existsSync()) {
      _log('Full sura audio file already cached: $fullSuraFilePath');
      Fluttertoast.showToast(msg: "Audio already downloaded");
      isDownloading = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<List<String>> _downloadVerseFiles(String suraName, int totalVerses, int suraNumber, String reciterIdentifier) async {
    final dio = Dio();
    final List<String> audioFilePaths = [];
    List<Map<String, dynamic>> verseNumberAndDuration = [];
    var startDuration = 0.0;

    for (int verse = 1; verse <= totalVerses; verse++) {
      final filePath = await AudioPathHelper.getVerseAudioPath(reciterIdentifier, suraName, verse);
      
      try {
        if (!File(filePath).existsSync()) {
          final audioUrl = quran.getAudioURLByVerse(suraNumber, verse, reciterIdentifier);
          _log('Downloading verse $verse from: $audioUrl');
          
          await dio.download(
            audioUrl, 
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = (received / total * 100).toStringAsFixed(0);
                _log('Download progress: $progress%');
              }
            }
          );
          final meta = await MetadataGod.readMetadata(file: filePath);
          if (meta.durationMs != null) {
            final duration = meta.durationMs!; // in milliseconds (int)

            verseNumberAndDuration.add({
              "verseNumber": verse,
              "startDuration": startDuration,
              "endDuration": startDuration + duration,
            });

            startDuration += duration;
          }
          // final metadata = await MetadataRetriever.fromFile(File(filePath));
          // if (metadata.trackDuration != null) {
          //   verseNumberAndDuration.add({
          //     "verseNumber": verse,
          //     "startDuration": startDuration,
          //     "endDuration": startDuration + metadata.trackDuration!
          //   });
          //   startDuration += metadata.trackDuration!;
          // }
        }
        audioFilePaths.add(filePath);
      } catch (e) {
        _log('Error downloading verse $verse: $e');
        Fluttertoast.showToast(msg: "Error downloading verse $verse");
        throw e;
      }
    }

    if (verseNumberAndDuration.isNotEmpty) {
      _saveVerseDurations(reciterIdentifier, suraName, verseNumberAndDuration);
    }

    return audioFilePaths;
  }

  void _saveVerseDurations(String reciterIdentifier, String suraName, List<Map<String, dynamic>> durations) {
    final durationKey = "$reciterIdentifier-${suraName.replaceAll(" ", "")}-durations";
    final jsonString = json.encode(durations);
    updateValue(durationKey, jsonString);
    _log('Saved verse durations with key: $durationKey');
  }

  Future<void> _combineAudioFiles(List<String> audioFilePaths, String fullSuraFilePath) async {
    final inputOptions = audioFilePaths.map((filePath) => '-i "${filePath.replaceAll('"', '\\"')}"').join(" ");
    final filterInputs = List.generate(audioFilePaths.length, (i) => "[$i:0]aresample=44100[a$i]").join(";");
    final filterConcat = List.generate(audioFilePaths.length, (i) => "[a$i]").join("");
    final outputPath = fullSuraFilePath.replaceAll('"', '\\"');
    
    final cmd = '$inputOptions -filter_complex "$filterInputs;${filterConcat}concat=n=${audioFilePaths.length}:v=0:a=1[aout]" -map "[aout]" -c:a mp3 -b:a 128k "$outputPath"';
    _log('Executing FFmpeg command: $cmd');

    final session = await FFmpegKit.execute(cmd);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      await _verifyOutputFile(fullSuraFilePath);
      _log("FFmpeg: Merging completed successfully!");
      Fluttertoast.showToast(msg: "Download completed");
    } else {
      final state = FFmpegKitConfig.sessionStateToString(await session.getState());
      final failStackTrace = await session.getFailStackTrace();
      final output = await session.getOutput();
      _log("FFmpeg Error: state:$state\nfailStackTrace:$failStackTrace\noutput:$output");
      Fluttertoast.showToast(msg: "Error combining audio files");
      throw Exception("FFmpeg error: ${returnCode?.getValue() ?? 'unknown error'}");
    }
  }

  Future<void> _verifyOutputFile(String filePath) async {
    final outputFile = File(filePath);
    if (!outputFile.existsSync() || await outputFile.length() == 0) {
      _log("FFmpeg Error: Output file missing or empty");
      throw Exception("FFmpeg error: Output file not created");
    }
  }
}