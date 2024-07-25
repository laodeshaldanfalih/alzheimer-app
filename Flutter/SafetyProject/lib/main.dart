import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:auto_size_text/auto_size_text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safety Report',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
  String? image, location, detectionStatus;
  File? _imageFile;
  DateTimeRange? _selectedDateRange; // Add variable for date range

  final db = FirebaseFirestore.instance;
  final picker = ImagePicker();

  // Pick image from gallery
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Compress image to ensure it is within the size limit
  Future<File?> compressImage(File file) async {
    final bytes = file.readAsBytesSync();
    final img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      print('Unable to decode image.');
      return null;
    }

    // Resize and compress image
    final resizedImage =
        img.copyResize(image, width: 100); // Adjust width as needed
    final compressedBytes =
        img.encodeJpg(resizedImage, quality: 85); // Adjust quality as needed

    // Save compressed image to temporary file
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp_image.jpg');
    tempFile.writeAsBytesSync(compressedBytes);

    return tempFile;
  }

  // Upload image to Firebase Storage and get URL
  Future<void> uploadImage() async {
    if (_imageFile == null) return;

    final compressedFile = await compressImage(_imageFile!);
    if (compressedFile == null) return;

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final destination = 'images/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(compressedFile);
      String imageUrl = await ref.getDownloadURL();

      setState(() {
        image = imageUrl;
      });

      print('Image uploaded: $imageUrl');
    } catch (e) {
      print('Error occurred while uploading image: $e');
    }
  }

  // Setters for form fields
  void getImage(String image) {
    this.image = image;
  }

  void getLocation(String location) {
    this.location = location;
  }

  void getDetectionStatus(String status) {
    this.detectionStatus = status;
  }

  // Create a new Firestore document
  Future<void> createData() async {
    await uploadImage();

    DocumentReference documentReference =
        db.collection("SafetyReport").doc(location);

    Map<String, dynamic> mapData = {
      "Image": image,
      "Location": location,
      "Safety Report": detectionStatus,
      "Time stamp": Timestamp.now()
    };

    documentReference.set(mapData).whenComplete(() {
      print("$location created");
    });
  }

  // Read Firestore document
  void readData() {
    DocumentReference documentReference =
        db.collection("SafetyReport").doc(location);

    documentReference.get().then((datasnapshot) {
      print(datasnapshot.data());
    });
  }

  // Update Firestore document
  void updateData() {
    DocumentReference documentReference =
        db.collection("SafetyReport").doc(location);

    Map<String, dynamic> mapData = {
      "Image": image,
      "Location": location,
      "Safety Report": detectionStatus,
      "Time stamp": Timestamp.now()
    };

    documentReference.set(mapData).whenComplete(() {
      print("$location updated");
    });
  }

  // Delete Firestore document
  void deleteData() {
    DocumentReference documentReference =
        db.collection("SafetyReport").doc(location);

    documentReference.delete().whenComplete(() {
      print("$location deleted");
    });
  }

  // Get status color based on detection status
  Color getStatusColor(String status) {
    switch (status) {
      case "No Googles":
        return Colors.blue;
      case "No Coat":
        return Colors.orange;
      case "No Helmet":
        return Colors.red;
      case "No Boots":
        return Colors.brown;
      default:
        return Colors.black;
    }
  }

  // Show date range picker and set state for date range
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter CRUD'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _imageFile == null
                    ? Text('No image selected.')
                    : Image.file(_imageFile!),
                ElevatedButton(
                  onPressed: pickImage,
                  child: Text('Pick Image'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Location",
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        )),
                    onChanged: (String location) {
                      getLocation(location);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Detection Status",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "No Googles", child: Text("No Googles")),
                      DropdownMenuItem(
                          value: "No Coat", child: Text("No Coat")),
                      DropdownMenuItem(
                          value: "No Helmet", child: Text("No Helmet")),
                      DropdownMenuItem(
                          value: "No Boots", child: Text("No Boots")),
                    ],
                    onChanged: (String? status) {
                      setState(() {
                        getDetectionStatus(status!);
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 2),
                        foregroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Create',
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        createData();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 2),
                        foregroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Read',
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        readData();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 2),
                        foregroundColor: Colors.orange,
                      ),
                      child: const Text(
                        'Update',
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        updateData();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 2),
                        foregroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Delete',
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        deleteData();
                      },
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.grey.withOpacity(0.7),
                    backgroundColor:
                        Colors.white, // Warna teks abu-abu dengan transparansi
                    side:
                        BorderSide(color: Colors.grey, width: 1), // Border biru
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Radius sudut
                    ),
                  ),
                  label: const Text('Select Date Range'),
                  icon: const Icon(Icons.edit_calendar_rounded, color: Colors.blue,),
                ),
                StreamBuilder(
                  stream: _selectedDateRange == null
                      ? db
                          .collection("SafetyReport")
                          .orderBy("Time stamp", descending: true)
                          .snapshots()
                      : db
                          .collection("SafetyReport")
                          .where("Time stamp",
                              isGreaterThanOrEqualTo: _selectedDateRange!.start)
                          .where("Time stamp",
                              isLessThanOrEqualTo: _selectedDateRange!.end)
                          .orderBy("Time stamp", descending: true)
                          .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Text('No reports found.');
                    } else {
                      return SizedBox(
                        height: MediaQuery.of(context)
                            .size
                            .height, // Adjust to screen height
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot documentSnapshot =
                                snapshot.data!.docs[index];
                            Map<String, dynamic> data =
                                documentSnapshot.data() as Map<String, dynamic>;

                            dynamic timestamp = data['Time stamp'];
                            String formattedDate;

                            if (timestamp is Timestamp) {
                              DateTime dateTime = timestamp.toDate();
                              formattedDate =
                                  DateFormat('MMMM d, yyyy \'at\' h:mm:ss a')
                                      .format(dateTime);
                            } else if (timestamp is int) {
                              DateTime dateTime =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      timestamp);
                              formattedDate =
                                  DateFormat('MMMM d, yyyy \'at\' h:mm:ss a')
                                      .format(dateTime);
                            } else {
                              formattedDate = 'No Timestamp';
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2.0, horizontal: 2.0),
                              child: Card(
                                elevation: 0,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 16, top: 16, bottom: 16),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: data['Image'] != null
                                            ? Image.network(
                                                data['Image'],
                                                height:
                                                    72, // Adjust height as needed
                                                width:
                                                    72, // Adjust width to make it square
                                                fit: BoxFit.cover,
                                              )
                                            : const SizedBox(
                                                height: 72,
                                                width: 72,
                                                child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 72),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            10), // Space between image and text
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AutoSizeText(
                                            data['Location'] ?? 'No Location',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          AutoSizeText(
                                            formattedDate,
                                            style:
                                                const TextStyle(fontSize: 12),
                                            maxLines: 2,
                                          ),
                                          const AutoSizeText(
                                            'ID 1234567890',
                                            style: TextStyle(fontSize: 2),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(8),
                                      child: AutoSizeText(
                                        '${data['Safety Report'] ?? 'No Status'}',
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: getStatusColor(
                                              data['Safety Report'] ?? ''),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
