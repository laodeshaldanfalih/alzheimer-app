import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/features/splash/presentation/pages/splash_page.dart';
import 'package:project/firebase_options.dart';
import 'package:provider/provider.dart' as provider;
import 'package:project/features/MMSE/data/mmse_test_state.dart';
import 'features/SKILAS/data/skilas_test_state.dart';
import 'package:project/features/GDS/data/gds_test_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => SKILASTestState()),
        provider.ChangeNotifierProvider(create: (context) => MMSETestState()),
        provider.ChangeNotifierProvider(create: (_) => GDSTestState()),
      ],
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashPage());
  }
}
