import 'dart:io';
import 'package:calm/Backend/api_call.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class TextToSpeech {
  TextToSpeech._privateConstructor();
  static final TextToSpeech _instance = TextToSpeech._privateConstructor();
  factory TextToSpeech() {
    return _instance;
  }

  final FlutterTts _flutterTts = FlutterTts();
  void initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts
        .setVoice({'name': 'en-us-x-sfg#male_1-local', 'locale': 'en-US'});
    await _flutterTts.setSpeechRate(0.3);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setEngine('com.google.android.tts');
  }

  void speak({required String text}) async {
    await _flutterTts.speak(text);
  }

  void pause() async {
    await _flutterTts.pause();
  }

  void stop() async {
    await _flutterTts.stop();
  }

  Future<dynamic> saveFile({required String text}) async {
    await requestAudioPermission();
    var deviceMusicDirectory =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_MUSIC);

    String audioFileName = 'output${UniqueKey()}.mp3';
    await _flutterTts.synthesizeToFile(text, audioFileName);
    await _flutterTts.awaitSynthCompletion(true);
    String formattedPath = audioFileName.replaceAll('/', '_');
    formattedPath = '$deviceMusicDirectory/$formattedPath';
    print(formattedPath);

    File audioFile = File(formattedPath);
    if (await audioFile.exists()) {
      print("File exists");
    } else {
      print("File does not exist");
    }
    return formattedPath;
  }
}
