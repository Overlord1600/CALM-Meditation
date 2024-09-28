import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

Future<void> requestAudioPermission() async {
  var status = await Permission.audio.status;
  if (!status.isGranted) {
    var result = await Permission.audio.request();
    if (result.isGranted) {
      print("Audio permission granted");
    } else if (result.isDenied) {
      print("Audio permission denied");
    } else if (result.isPermanentlyDenied) {
      print("Audio permission permanently denied");
      openAppSettings();
    }
  } else {
    print("Audio permission already granted.");
  }
}

Future<String?> sendFilesToServerForMasking({required String filePath1}) async {
  var req = http.MultipartRequest("POST", Uri.parse(dotenv.env["API_URL"]!));
  req.files.add(await http.MultipartFile.fromPath("audio1", filePath1));

  try {
    var streamedResponse = await req.send();
    if (streamedResponse.statusCode == 200) {
      print('Files uploaded successfully');

      var deviceMusicDirectory =
          await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_MUSIC);
      String filePath = '$deviceMusicDirectory/final_output${UniqueKey()}.mp3';
      File file = File(filePath);

      var sink = file.openWrite();
      await streamedResponse.stream.pipe(sink);      
      await sink.close();

      if (await file.exists()) {
        print("Output file at $filePath");
        return file.path;
      } else {
        print("Failed");
        return null;
      }
    } else {
      print(
          'Failed to upload files. Status code: ${streamedResponse.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error during file upload and download: $e');
    return null;
  }
}
