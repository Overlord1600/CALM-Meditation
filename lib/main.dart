import 'package:calm/Screens/demo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  dotenv.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Expanded(child: DemoScreen())],
        ),
      ),
    );
  }
}

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  double _start = 0.0;
  final double _limit = 500;
  double _startControllerVal = 0.0;
  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation =
        ColorTween(begin: Colors.amber, end: Colors.red).animate(_controller);
    super.initState();
  }

  void onDragStart(DragStartDetails d) {
    _start = d.localPosition.dy;
    _startControllerVal = _controller.value;
  }

  void dragUpdate(DragUpdateDetails d) {
    final diff = d.localPosition.dy - _start;
    final perc = diff / _limit;
    final newContVal = (_startControllerVal - perc).clamp(0.0, 1.0);
    _controller.value = newContVal;
  }

  void dragEnd(DragEndDetails d) {
    if (_controller.value < 0.5) {
      _controller.animateTo(0.0, duration: const Duration(milliseconds: 300));
    } else {
      _controller.animateTo(1.0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return GestureDetector(
                onVerticalDragEnd: dragEnd,
                onVerticalDragStart: onDragStart,
                onVerticalDragUpdate: dragUpdate,
                child: Container(
                  color: _animation.value,
                  height: 500,
                  width: 500,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
