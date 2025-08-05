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
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Walk Mapper Background Service",
    notificationText: "Walk Mapper is running in the background",
    notificationImportance: AndroidNotificationImportance.max,
    // enableWifiLock: true,
     notificationIcon: AndroidResource(
	    name: 'background_icon',
	    defType: 'drawable'
	  ),
  );

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, 
  ]);
  

  // initialise app - with background task permission check

  bool hasPermissions = await FlutterBackground.initialize(androidConfig: androidConfig);
  
  // this is dumb but may be necessary on first run
  if (!hasPermissions) {
    hasPermissions = await FlutterBackground.initialize(androidConfig: androidConfig);
  }
  
  if (hasPermissions){
  //bool success = await FlutterBackground.enableBackgroundExecution();
  //if (success){
    if (await FlutterBackground.enableBackgroundExecution()){
      runApp(const MyApp());
    }
    // if you cant get background permission, exit the app
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
      title: 'Walk Mapper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(
        ),
    );
  }
}

