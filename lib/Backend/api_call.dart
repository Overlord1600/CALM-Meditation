import 'dart:io';
import 'package:external_path/external_path.dart';
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
  req.fields['pitch_factor'] = "0.8";
  req.fields['speed_factor'] = "1.0";
  var response = await req.send();

  if (response.statusCode == 200) {
    print('Files uploaded successfully');
    var deviceMusicDirectory =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_MUSIC);
    String filePath = '$deviceMusicDirectory/final_output.mp3';
    File file = File(filePath);

    if (await file.exists()) {
      print("Output file exists");
    }

    return file.path;
  } else {
    print('Failed to upload files. Status code: ${response.statusCode}');
    return null;
  }
}
