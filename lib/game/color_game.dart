import 'dart:math';
import 'package:flutter/material.dart';

class ColorGame extends StatefulWidget {
  const ColorGame({super.key});

  @override
  State<ColorGame> createState() => _ColorGameState();
}

class _ColorGameState extends State<ColorGame> {
  final Map<String, bool> score = {};

  final Map choices = {
    '🥬': Colors.green,
    '🍋': Colors.yellow,
    '🍎': Colors.red,
    '🫘': Colors.brown,
    '🥕': Colors.orange,
    '🍇': Colors.purple,
  };

  int seed = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skor ${score.length} / 6'),
        backgroundColor: Colors.lightBlue,
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          setState(() {
            score.clear();
            seed++;
          });
        },
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.refresh),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey[100]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  choices.keys.map((emoji) {
                    return Draggable<String>(
                      data: emoji,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Emoji(emoji: emoji, size: 60),
                      ),
                      childWhenDragging: const Emoji(
                        emoji: "🔳",
                        size: 50,
                        opacity: 0.3,
                      ),
                      child: Emoji(
                        emoji: score[emoji] == true ? '✅' : emoji,
                        size: 50,
                      ),
                    );
                  }).toList(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  choices.keys.map((emoji) => _buildDragTarget(emoji)).toList()
                    ..shuffle(Random(seed)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragTarget(emoji) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        if (score[emoji] == true) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            height: 80,
            width: 120,
            margin: const EdgeInsets.all(10),
            child: const Text(
              "Benar",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          );
        } else {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color:
                  candidateData.isNotEmpty
                      ? choices[emoji].withOpacity(0.7)
                      : choices[emoji],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            height: 80,
            width: 120,
            margin: const EdgeInsets.all(10),
          );
        }
      },
      onWillAcceptWithDetails: (details) {
        return details.data == emoji;
      },
      onAcceptWithDetails: (details) {
        setState(() {
          score[emoji] = true;
          if (score.length == choices.length) {
            Future.delayed(const Duration(milliseconds: 500), () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Selesai!"),
                    content: const Text("Berhasil Mencocokkan Semua Warnanya!"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            score.clear();
                            seed++;
                          });
                        },
                        child: const Text("Mainkan Lagi"),
                      ),
                    ],
                  );
                },
              );
            });
          }
        });
      },

      onLeave: (data) {},
    );
  }
}

class Emoji extends StatelessWidget {
  const Emoji({
    super.key,
    required this.emoji,
    this.size = 50,
    this.opacity = 1.0,
  });

  final String emoji;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.none,
      child: Container(
        alignment: Alignment.center,
        height: size,
        child: Opacity(
          opacity: opacity,
          child: Text(
            emoji,
            style: TextStyle(fontSize: 30, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
