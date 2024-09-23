import 'package:calm/AI%20services/Text%20Generation/text_generation.dart';
import 'package:calm/Screens/text_to_voice_demo.dart';
import 'package:flutter/material.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  late TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  Future<String>? text;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
          future: text,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              if (text == null) {
                return Column(children: [
                  TextField(
                    decoration: const InputDecoration(hintText: "Enter prompt"),
                    controller: _controller,
                  ),
                  ElevatedButton(
                    child: const Text("Generate response"),
                    onPressed: () async {
                      setState(() {
                        text = TextGeneration()
                            .sendPrompt(prompt: _controller.text);
                      });
                    },
                  ),
                ]);
              } else {
                return SingleChildScrollView(
                    child: Column(children: [
                  Text(snapshot.data!),
                  ElevatedButton(
                    child: const Text("Generate response"),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return TTSExample(text: snapshot.data!);
                        },
                      ));
                    },
                  ),
                ]));
              }
            }
          }),
    );
  }
}
