import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Paint Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

enum ShowType { Random, SideBySide }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  List<Offset> lines = [];
  final int numberOfLines = 10;
  ShowType showType = ShowType.Random;
  final random = Random();

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    lines = linesGenerator(MediaQuery.of(context).size);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              _animationController.stop();
            },
            icon: const Icon(Icons.stop),
          ),
          IconButton(
            onPressed: () {
              _animationController.forward();
            },
            icon: const Icon(Icons.play_arrow),
          ),
          IconButton(
            onPressed: () {
              _animationController.repeat(reverse: true);
            },
            icon: const Icon(Icons.repeat),
          )
        ],
      ),
      drawer: SafeArea(
        child: Drawer(
          child: Column(
            children: <Widget>[
              ListTile(
                selected: showType == ShowType.Random,
                selectedColor: Colors.red,
                onTap: () {
                  setState(() {
                    showType = ShowType.Random;
                  });
                },
                title: const Text('Random'),
                subtitle: const Divider(),
              ),
              ListTile(
                selected: showType == ShowType.SideBySide,
                selectedColor: Colors.red,
                onTap: () {
                  setState(() {
                    showType = ShowType.SideBySide;
                  });
                },
                title: const Text('Side By Side'),
                subtitle: const Divider(),
              ),
            ],
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            foregroundPainter: LaserCustomPaint(
                animation: _animationController.view,
                numberOfLines: numberOfLines,
                lines: lines,
                showType: showType),
            child: Container(
              color: Colors.black,
            ),
          );
        },
      ),
    );
  }

  List<Offset> linesGenerator(Size size) {
    if (showType == ShowType.Random) {
      return lines = generateRandomLines(size);
    }
    return lines = generateSideBySideLines(size);
  }

  List<Offset> generateRandomLines(Size size) {
    final List<Offset> lines = [];
    const spacing = 90;
    for (int i = 0; i < numberOfLines; i++) {
      if (showType == ShowType.Random) {
        // Generate line from top to right of
        if (i % 2 == 0) {
          final startX = (random.nextDouble() * 250.0) + (i * spacing);
          const startY = 0.0;
          final endX = size.width; // Add size.width so it will go across screen
          final endY = (random.nextDouble() * size.height) + size.height;

          final startOffset = Offset(startX, startY);
          final endOffset = Offset(endX, endY + (i * spacing));
          print('Top offset:  start$startOffset  End $endOffset ');
          lines.add(startOffset);
          lines.add(endOffset);
        } else {
          // Generate line from right to Left of
          final startX = (random.nextDouble() * -100.0) - (i * spacing);
          final startY = random.nextDouble() * size.height;
          final endX = (random.nextDouble() * size.width) +
              size.width; // Add size.width so it will go across screen
          final endY = (random.nextDouble() * size.height) + size.height / 2;
          final startOffset = Offset(startX, startY);
          final endOffset = Offset(endX, endY + (i * spacing));
          print('offset:  start$startOffset  End $endOffset ');
          lines.add(startOffset);
          lines.add(endOffset);
        }
      }
    }
    return lines;
  }

  List<Offset> generateSideBySideLines(Size size) {
    const spacing = 40.0;
    final List<Offset> lines = [];
    for (int i = 0; i < numberOfLines; i++) {
      if (i % 2 == 0) {
        const startX = 0.0;
        final startY = i * spacing;
        final endX = size.width; // Add size.width so it will go across screen
        final endY = (i * spacing) + size.height / 2;
        final startOffset = Offset(startX, startY);
        final endOffset = Offset(endX, endY);
        lines.add(startOffset);
        lines.add(endOffset);
      } else {
        final startX = size.width;
        final startY = i * spacing;
        const endX = 0.0; // Add size.width so it will go across screen
        final endY = (i * spacing) + size.height / 2;
        final startOffset = Offset(startX, startY);
        final endOffset = Offset(endX, endY);
        lines.add(startOffset);
        lines.add(endOffset);
      }
    }
    return lines;
  }
}

class LaserCustomPaint extends CustomPainter {
  final int numberOfLines;
  final Animation<double> animation;
  final List<Offset> lines;
  final ShowType showType;
  Paint linePaint = Paint();

  LaserCustomPaint({
    required this.numberOfLines,
    required this.animation,
    required this.lines,
    required this.showType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    linePaint.style = PaintingStyle.fill;
    linePaint.strokeWidth = 2;
    linePaint.strokeCap = StrokeCap.round;
    linePaint.shader = const LinearGradient(
      colors: [Colors.red, Colors.yellow],
    ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    for (int i = 0; i < lines.length; i += 2) {
      final offsetStart = lines[i];
      final offsetEnd = lines[i + 1];

      if (showType == ShowType.Random) {
        if (offsetStart.dy == 0.0) {
          // Generate line from top to right of
          final p1 = Offset(
              offsetStart.dx * sin(animation.value * pi), offsetStart.dy);
          final p2 = Offset(
              offsetEnd.dx - (offsetEnd.dx * animation.value), offsetEnd.dy);
          canvas.drawLine(p1, p2, linePaint);
        } else {
          final p1 =
              Offset(offsetStart.dx * sin(animation.value), offsetStart.dy);
          final p2 = Offset(offsetEnd.dx, offsetEnd.dy * animation.value);
          canvas.drawLine(p1, p2, linePaint);
        }
      } else {
        final p1 = Offset(offsetStart.dx, offsetStart.dy);
        final p2 = Offset(offsetEnd.dx,
            offsetEnd.dy + ((offsetEnd.dy * pi) * cos(animation.value * pi)));
        canvas.drawLine(p1, p2, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
