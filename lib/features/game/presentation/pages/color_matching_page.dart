import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ColorMatchingPage extends StatefulWidget {
  const ColorMatchingPage({super.key});

  @override
  State<ColorMatchingPage> createState() => _ColorGameState();
}

class _ColorGameState extends State<ColorMatchingPage> {
  final Map<String, bool> score = {};
  final Map<String, Color> choices = {
    '🥬': Colors.green,
    '🍋': Colors.yellow,
    '🍎': Colors.red,
    '🤎': Colors.brown,
    '🥕': Colors.orange,
    '🍇': Colors.purple,
  };

  int seed = 0;
  bool showWinOverlay = false;
  double overlayOpacity = 0.0;

  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _playSound(String fileName) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/$fileName'));
  }

  void _showWinOverlay() async {
    _confettiController.play();
    _playSound('win.mp3');

    setState(() {
      showWinOverlay = true;
      overlayOpacity = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => overlayOpacity = 1.0);
  }

  void _restartGame() {
    setState(() {
      score.clear();
      seed++;
      showWinOverlay = false;
      overlayOpacity = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final emojis = choices.keys.toList()..shuffle(Random(seed));

    return Scaffold(
      appBar: AppBar(title: const Text('Color Game')),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  "Skor: ${score.length} / ${choices.length}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Emoji List
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children:
                            emojis.map((emoji) {
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

                      // Color Boxes
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            emojis
                                .map((emoji) => _buildDragTarget(emoji))
                                .toList()
                              ..shuffle(Random(seed)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              maxBlastForce: 10,
              minBlastForce: 5,
              colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange],
            ),
          ),

          // Restart Button
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.lightBlue,
              onPressed: _restartGame,
              child: const Icon(Icons.refresh),
            ),
          ),

          // Win Overlay
          if (showWinOverlay)
            AnimatedOpacity(
              opacity: overlayOpacity,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "🎉 KAMU MENANG!",
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _restartGame,
                        child: const Text("Main Lagi"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDragTarget(String emoji) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        if (score[emoji] == true) {
          return _buildResultBox("Benar", Colors.green);
        } else {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 80,
            width: 120,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  candidateData.isNotEmpty
                      ? choices[emoji]!.withOpacity(0.7)
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
          );
        }
      },
      onWillAccept: (data) => data == emoji,
      onAccept: (data) {
        setState(() {
          score[emoji] = true;

          if (score.length == choices.length) {
            _showWinOverlay();
          }
        });
      },
    );
  }

  Widget _buildResultBox(String text, Color color) {
    return Container(
      height: 80,
      width: 120,
      margin: const EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
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
    return Container(
      alignment: Alignment.center,
      height: size,
      child: Opacity(
        opacity: opacity,
        child: Text(emoji, style: TextStyle(fontSize: 30, color: Colors.black)),
      ),
    );
  }
}
