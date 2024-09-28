
import 'package:calm/Screens/final_audio_player.dart';
import 'package:calm/Text%20to%20Speech/text_to_speech.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSExample extends StatefulWidget {
  final String text;
  const TTSExample({super.key, required this.text});

  @override
  State<TTSExample> createState() => _TTSExampleState();
}

class _TTSExampleState extends State<TTSExample> {
  FlutterTts flutterTts = FlutterTts();
  TextToSpeech tts = TextToSpeech();
  Future<dynamic>? dynamicState;
  late Function processAndPlayAudio;
  @override
  void initState() {
    tts.initTts();
    dynamicState = tts.saveFile(text: widget.text);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Text to Speech Example"),
        ),
        body: Center(
          child: FutureBuilder(
            future: dynamicState,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                  return Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            tts.speak(text: widget.text);
                          },
                          child: const Text("Speak"),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              tts.pause();
                            },
                            child: const Text("Pause")),
                        ElevatedButton(
                            onPressed: () {
                              tts.stop();
                            },
                            child: const Text("Stop")),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return FinalAudioPlayer(
                        path: snapshot.data,
                      );
                    },
                  ));
                            },
                            child: const Text("Merge file with masking audio"))
                      ],
                    ),
                  );
                
              } else {
                return const Text("NULL");
              }
            },
          ),
        )
        //
        );
  }
}
