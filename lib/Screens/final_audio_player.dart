import 'package:calm/Backend/api_call.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class FinalAudioPlayer extends StatefulWidget {
  final String path;
  const FinalAudioPlayer({super.key, required this.path});
  @override
  State<FinalAudioPlayer> createState() => _FinalAudioPlayerState();
}

class _FinalAudioPlayerState extends State<FinalAudioPlayer> {
  late AudioPlayer player;
  @override
  void initState() {
    player = AudioPlayer();
    super.initState();
  }

  Future<void> initAudioReqs() async {
    final finalPath = await sendFilesToServerForMasking(filePath1: widget.path);
    await player.setFilePath(finalPath!);
    await player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: initAudioReqs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("PLAYING");
            } else {
              return const Text("PLAYING COMPLETED");
            }
          },
        ),
      ),
    );
  }
}
