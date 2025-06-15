import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:project/features/game/domain/models/quick_food_item.dart';
import 'package:audioplayers/audioplayers.dart';

class FoodStackPage extends StatefulWidget {
  const FoodStackPage({super.key});

  @override
  State<FoodStackPage> createState() => _FoodStackPageState();
}

class _FoodStackPageState extends State<FoodStackPage> {
  late List<QuickFoodItem> originalQuickFoods;
  List<QuickFoodItem> allQuickFoods = [];
  List<QuickFoodItem> availableQuickFoods = [];
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Map<FoodCategory, QuickFoodItem?> droppedItems = {
    FoodCategory.Lauk: null,
    FoodCategory.Karbo: null,
    FoodCategory.Buah: null,
    FoodCategory.Sayur: null,
  };

  String? draggedItemTitle;
  bool showWinOverlay = false;
  bool showLoseOverlay = false;
  double overlayOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    originalQuickFoods = [
      QuickFoodItem(
        title: "Daging Sapi",
        image: '🥩',
        onTap: () {},
        category: FoodCategory.Lauk,
      ),
      QuickFoodItem(
        title: "Telur",
        image: '🥚',
        onTap: () {},
        category: FoodCategory.Lauk,
      ),
      QuickFoodItem(
        title: "Ikan",
        image: '🐟',
        onTap: () {},
        category: FoodCategory.Lauk,
      ),
      QuickFoodItem(
        title: "Nasi",
        image: '🍚',
        onTap: () {},
        category: FoodCategory.Karbo,
      ),
      QuickFoodItem(
        title: "Kentang",
        image: '🥔',
        onTap: () {},
        category: FoodCategory.Karbo,
      ),
      QuickFoodItem(
        title: "Singkong",
        image: '🌱',
        onTap: () {},
        category: FoodCategory.Sayur,
      ),
      QuickFoodItem(
        title: "Pisang",
        image: '🍌',
        onTap: () {},
        category: FoodCategory.Buah,
      ),
      QuickFoodItem(
        title: "Apel",
        image: '🍎',
        onTap: () {},
        category: FoodCategory.Buah,
      ),
      QuickFoodItem(
        title: "Mangga",
        image: '🥭',
        onTap: () {},
        category: FoodCategory.Buah,
      ),
      QuickFoodItem(
        title: "Bayam",
        image: '🥬',
        onTap: () {},
        category: FoodCategory.Sayur,
      ),
      QuickFoodItem(
        title: "Wortel",
        image: '🥕',
        onTap: () {},
        category: FoodCategory.Sayur,
      ),
      QuickFoodItem(
        title: "Kangkung",
        image: '🌿',
        onTap: () {},
        category: FoodCategory.Sayur,
      ),
    ];

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    resetGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _playSound(String fileName) async {
    await _audioPlayer.play(AssetSource('sounds/$fileName'));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double boxSize = screenWidth * 0.2;
    double spacing = 10;
    double itemWidth = (screenWidth - ((2 + 1) * spacing)) / 2;
    double itemHeight = itemWidth;
    double aspectRatio = itemWidth / (itemHeight * 0.8);

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(17),
                    width: double.infinity,
                    decoration: BoxDecoration(color: Color(0xffAFDBC5)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Menyusun Menu Makanan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.06,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            height: screenWidth * 0.8,
                            width: screenWidth * 0.8,
                            margin: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.5,
                                color: Colors.grey,
                              ),
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              children: [
                                buildDragTarget(
                                  FoodCategory.Lauk,
                                  screenWidth,
                                  boxSize,
                                  right: screenWidth * 0.04,
                                  top: (screenWidth * 0.8 / 2) - (boxSize / 2),
                                ),
                                buildDragTarget(
                                  FoodCategory.Karbo,
                                  screenWidth,
                                  boxSize,
                                  left: screenWidth * 0.04,
                                  top: (screenWidth * 0.8 / 2) - (boxSize / 2),
                                ),
                                buildDragTarget(
                                  FoodCategory.Buah,
                                  screenWidth,
                                  boxSize,
                                  left: (screenWidth * 0.8 / 2) - (boxSize / 2),
                                  top: screenWidth * 0.04,
                                ),
                                buildDragTarget(
                                  FoodCategory.Sayur,
                                  screenWidth,
                                  boxSize,
                                  left: (screenWidth * 0.8 / 2) - (boxSize / 2),
                                  bottom: screenWidth * 0.04,
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: ConfettiWidget(
                                    confettiController: _confettiController,
                                    blastDirectionality:
                                        BlastDirectionality.explosive,
                                    shouldLoop: false,
                                    numberOfParticles: 30,
                                    maxBlastForce: 10,
                                    minBlastForce: 5,
                                    colors: const [
                                      Colors.green,
                                      Colors.blue,
                                      Colors.pink,
                                      Colors.orange,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: 15,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: availableQuickFoods.length,
                        itemBuilder: (context, index) {
                          return Draggable<QuickFoodItem>(
                            data: availableQuickFoods[index],
                            onDragStarted: () {
                              setState(() {
                                draggedItemTitle =
                                    availableQuickFoods[index].title;
                              });
                            },
                            onDragEnd: (_) {
                              setState(() {
                                draggedItemTitle = null;
                              });
                            },
                            feedback: Material(
                              color: Colors.transparent,
                              child: Transform.translate(
                                offset: Offset(60, 30),
                                child: _buildQuickFoodItem(
                                  availableQuickFoods[index],
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _buildQuickFoodItem(
                                availableQuickFoods[index],
                              ),
                            ),
                            child: _buildQuickFoodItem(
                              availableQuickFoods[index],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showWinOverlay)
            AnimatedOpacity(
              opacity: overlayOpacity,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "🎉 KAMU MENANG!",
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showWinOverlay = false;
                              resetGame();
                            });
                          },
                          child: Text("Main Lagi"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (showLoseOverlay)
            AnimatedOpacity(
              opacity: overlayOpacity,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "😓 Coba Lagi!",
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showLoseOverlay = false;
                              resetGame();
                            });
                          },
                          child: const Text("Ulangi"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDragTarget(
    FoodCategory category,
    double screenWidth,
    double boxSize, {
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: DragTarget<QuickFoodItem>(
        builder: (context, candidateData, rejectedData) {
          final dropped = droppedItems[category];

          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: boxSize,
              height: boxSize,
              child: Center(
                child:
                    dropped == null
                        ? DottedBorder(
                          color: Colors.grey,
                          strokeWidth: 2,
                          dashPattern: [7, 7],
                          child: Center(
                            child: Text(
                              category.toString().split('.').last,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                        : Draggable<QuickFoodItem>(
                          data: dropped,
                          onDragStarted: () {
                            setState(() {
                              draggedItemTitle = dropped.title;
                              droppedItems[category] = null;
                              if (!availableQuickFoods.contains(dropped)) {
                                availableQuickFoods.add(dropped);
                              }
                            });
                          },
                          onDragEnd: (_) {
                            setState(() {
                              draggedItemTitle = null;
                            });
                          },
                          feedback: Material(
                            color: Colors.transparent,
                            child: _buildQuickFoodItem(dropped),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildQuickFoodItem(dropped),
                          ),
                          child: _buildQuickFoodItem(dropped),
                        ),
              ),
            ),
          );
        },
        onAccept: (item) {
          setState(() {
            droppedItems.updateAll(
              (key, value) => value == item ? null : value,
            );
            droppedItems[category] = item;
            availableQuickFoods.remove(item);
            if (droppedItems.values.every((item) => item != null)) {
              _checkForWin();
            }
          });
        },
      ),
    );
  }

  void _checkForWin() {
    bool allCorrect = droppedItems.entries.every(
      (entry) => entry.value?.category == entry.key,
    );
    if (allCorrect) {
      _showWinDialog();
    } else {
      _showIncorrectPlacementDialog();
    }
  }

  void _showWinDialog() async {
    _confettiController.play();
    await Future.delayed(Duration(seconds: 2));
    _playSound('win.mp3');

    setState(() {
      showWinOverlay = true;
      overlayOpacity = 0.0;
    });

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() => overlayOpacity = 1.0);
    });
  }

  void _showIncorrectPlacementDialog() {
    _playSound('fail.mp3');

    setState(() {
      showLoseOverlay = true;
      overlayOpacity = 0.0;
    });

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() => overlayOpacity = 1.0);
    });
  }

  Widget _buildQuickFoodItem(QuickFoodItem item) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.image, style: TextStyle(fontSize: 40)),
          Flexible(
            child: Text(
              item.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      droppedItems = {
        FoodCategory.Lauk: null,
        FoodCategory.Karbo: null,
        FoodCategory.Buah: null,
        FoodCategory.Sayur: null,
      };

      List<QuickFoodItem> previous = List.from(allQuickFoods);
      List<QuickFoodItem> selected = [];
      for (var cat in FoodCategory.values) {
        final items =
            originalQuickFoods.where((i) => i.category == cat).toList()
              ..shuffle();
        for (var item in items) {
          if (!previous.contains(item)) {
            selected.add(item);
            break;
          }
        }
      }
      allQuickFoods = selected;
      availableQuickFoods = List.from(selected);
    });
  }
}
