import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

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
      title: 'Flutter CRUD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
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
  DateTime? timeStamp;

  final db = FirebaseFirestore.instance;

  getImage(image) {
    this.image = image;
  }

  getTimeStamp(time) {
    this.timeStamp = time;
  }

  getLocation(location) {
    this.location = location;
  }

  getDetectionStatus(status) {
    this.detectionStatus = status;
  }

  // getDate(date) {
  //   this.date = date;
  // }

  createData() {
    DocumentReference documentReference =
        db.collection("SafetyReport").doc(location);

    Map<String, dynamic> mapData = {
      "Image": image,
      "Location": location,
      "Safety Report": detectionStatus,
      "Time stamp": DateTime.now().millisecondsSinceEpoch
    };

    documentReference.set(mapData).whenComplete(() {
      print("$location created");
    });
  }

  readData() {
    DocumentReference documentReference =
        db.collection("SafetyReport").doc(location);

    documentReference.get().then((datasnapshot) {
      print(datasnapshot.data());
      print(datasnapshot.data());
      print(datasnapshot.data());
    });
  }

  updateData() {
    DocumentReference documentReference =
        db.collection("SafetyReport").doc(location);

    Map<String, dynamic> mapData = {
      "Image": image,
      "Location": location,
      "Safety Report": detectionStatus,
      "Time stamp": DateTime.now().millisecondsSinceEpoch
    };

    documentReference.set(mapData).whenComplete(() {
      print("$location updated");
    });
  }

  deleteData() {
    DocumentReference documentReference =
        db.collection("SafetyReport").doc(location);

    documentReference.delete().whenComplete(() {
      print("$location deleted");
    });
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
            margin: const EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Image",
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        )),
                    onChanged: (String image) {
                      getImage(image);
                    },
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8),
                //   child: TextFormField(
                //     decoration: const InputDecoration(
                //         labelText: "Time Stamp",
                //         fillColor: Colors.white,
                //         focusedBorder: OutlineInputBorder(
                //           borderSide:
                //               BorderSide(color: Colors.blue, width: 2.0),
                //         )),
                //     onChanged: (String time) {
                //       getTimeStamp(time);
                //     },
                //   ),
                // ),

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
                  child: TextFormField(
                    decoration: const InputDecoration(
                        labelText: "Detection Status",
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        )),
                    onChanged: (status) {
                      getDetectionStatus(status);
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

                StreamBuilder(
                  stream: db.collection("SafetyReport").snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Text('No reports found.');
                    } else {
                      return SizedBox(
                        height:
                            300, // Set a fixed height to avoid infinite height issues
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot documentSnapshot =
                                snapshot.data!.docs[index];
                            Map<String, dynamic> data =
                                documentSnapshot.data() as Map<String, dynamic>;

                            return ListTile(
                              title: Text(data['Location'] ?? 'No Location'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Image: ${data['Image'] ?? 'No Image'}'),
                                  Text(
                                      'Status: ${data['Safety Report'] ?? 'No Status'}'),
                                  Text(
                                      'Timestamp: ${DateTime.fromMillisecondsSinceEpoch(data['Time stamp'] ?? 0)}'),
                                ],
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
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
