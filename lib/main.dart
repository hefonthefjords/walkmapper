import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:walkmapper/classes/boxes.dart';
import 'package:walkmapper/classes/latlng_adapter.dart';
import 'package:walkmapper/classes/walk.dart';
import 'package:walkmapper/pages/homepage.dart';
import 'package:flutter_background/flutter_background.dart';

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

  // add background task things
  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Background Task Example",
    notificationText: "Running in the background",
    notificationImportance: AndroidNotificationImportance.high,
    enableWifiLock: true,
  );

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, 
  ]);
  

  // initialise app - with background task permission check

  bool hasPermissions = await FlutterBackground.initialize(androidConfig: androidConfig);
  
  if (hasPermissions) {
  
    bool success = await FlutterBackground.enableBackgroundExecution();
    if (success){
      runApp(const MyApp());
    }
    else {
      exit(1);
    }
  }
  
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

