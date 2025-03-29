import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:project/features/game/domain/models/quick_food_item.dart';

class MenyusunMakananPage extends StatefulWidget {
  const MenyusunMakananPage({super.key});

  @override
  State<MenyusunMakananPage> createState() => _MenyusunMakananPageState();
}

class _MenyusunMakananPageState extends State<MenyusunMakananPage> {
  late List<QuickFoodItem> originalQuickFoods;
  List<QuickFoodItem> allQuickFoods = [];
  List<QuickFoodItem> availableQuickFoods = [];

  Map<FoodCategory, QuickFoodItem?> droppedItems = {
    FoodCategory.Lauk: null,
    FoodCategory.Karbo: null,
    FoodCategory.Buah: null,
    FoodCategory.Sayur: null,
  };

  String? draggedItemTitle;

  @override
  void initState() {
    super.initState();

    originalQuickFoods = [
      QuickFoodItem(
        title: "Daging Sapi",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Lauk,
      ),
      QuickFoodItem(
        title: "Telur",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Lauk,
      ),
      QuickFoodItem(
        title: "Ikan",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Lauk,
      ),
      QuickFoodItem(
        title: "Nasi",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Karbo,
      ),
      QuickFoodItem(
        title: "Kentang",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Karbo,
      ),
      QuickFoodItem(
        title: "Singkong",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Karbo,
      ),
      QuickFoodItem(
        title: "Pisang",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Buah,
      ),
      QuickFoodItem(
        title: "Apel",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Buah,
      ),
      QuickFoodItem(
        title: "Mangga",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Buah,
      ),
      QuickFoodItem(
        title: "Bayam",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Sayur,
      ),
      QuickFoodItem(
        title: "Wortel",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Sayur,
      ),
      QuickFoodItem(
        title: "Kangkung",
        image: 'assets/images/google_icons.png',
        onTap: () {},
        category: FoodCategory.Sayur,
      ),
    ];

    resetGame();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double boxSize = 90;
    int crossAxisCount = 2;
    double spacing = 10;
    double itemWidth =
        (screenWidth - ((crossAxisCount + 1) * spacing)) / crossAxisCount;
    double itemHeight = itemWidth;
    double aspectRatio = itemWidth / (itemHeight * 0.8);

    return Scaffold(
      appBar: AppBar(),
      body: Column(
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                      border: Border.all(width: 0.5, color: Colors.grey),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: spacing,
                mainAxisSpacing: 15,
                childAspectRatio: aspectRatio,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(availableQuickFoods.length, (index) {
                  return Draggable<QuickFoodItem>(
                    data: availableQuickFoods[index],
                    onDragStarted: () {
                      setState(() {
                        draggedItemTitle = availableQuickFoods[index].title;
                      });
                    },
                    onDragEnd: (_) {
                      setState(() {
                        draggedItemTitle = null;
                      });
                    },
                    feedback: Material(
                      color: Colors.transparent,
                      child: _buildQuickFoodItem(availableQuickFoods[index]),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildQuickFoodItem(availableQuickFoods[index]),
                    ),
                    child: _buildQuickFoodItem(availableQuickFoods[index]),
                  );
                }),
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
            // Hapus item dari semua slot yang mungkin menyimpan item ini
            droppedItems.updateAll((key, value) {
              if (value == item) return null;
              return value;
            });

            // Tambahkan ke kategori baru
            droppedItems[category] = item;

            // Hapus dari menu bawah (sekali saja)
            availableQuickFoods.remove(item);

            // Cek apakah semua slot sudah terisi
            bool allFilled = droppedItems.values.every((item) => item != null);
            if (allFilled) _checkForWin();
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

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Congratulations!"),
          content: Text(
            "You've successfully placed all items in the correct categories!",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text("Restart Game"),
            ),
          ],
        );
      },
    );
  }

  void _showIncorrectPlacementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Incorrect Placement"),
          content: Text("Some items are placed incorrectly. Please try again!"),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              child: Text("Try Again"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickFoodItem(QuickFoodItem item) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(item.image, width: 60, height: 60, fit: BoxFit.contain),
          SizedBox(height: 10),
          Text(
            item.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
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

      List<QuickFoodItem> selected = [];
      for (var cat in FoodCategory.values) {
        final items =
            originalQuickFoods.where((i) => i.category == cat).toList()
              ..shuffle();
        if (items.isNotEmpty) selected.add(items.first);
      }

      allQuickFoods = selected;
      availableQuickFoods = List.from(selected);
    });
  }
}
