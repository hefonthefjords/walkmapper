import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:walkmapper/classes/boxes.dart';
import 'package:walkmapper/classes/latlng_adapter.dart';
import 'package:walkmapper/classes/walk.dart';
import 'package:walkmapper/pages/homepage.dart';

// this is historic from trying to use .env - will figure out later
// import 'package:flutter_config/flutter_config.dart';

void main() async {
  // this is historic form trying to figure out .env - will figure out later
  // WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  // await FlutterConfig.loadEnvVariables();

  // hive setup things
  await Hive.initFlutter();
  Hive.registerAdapter(WalkAdapter());
  Hive.registerAdapter(LatLngAdapterAdapter());
  boxWalk = await Hive.openBox<Walk>("boxWalk");
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walk mApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(
        ),
    );
  }
}

