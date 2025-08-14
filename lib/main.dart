import 'dart:ui';
import 'dart:html' as html;
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fkdatahub/Authentication/Screens/Login/login_screen_1.dart';
import 'package:fkdatahub/Authentication/services/version_checker.dart';
import 'package:fkdatahub/firebase_options.dart';
//import 'package:fkdatahub/retaildata/payment/home.dart';
import 'package:fkdatahub/retaildata/retail_home.dart';
import 'package:fkdatahub/splashscreen.dart';
import 'package:fkdatahub/updatechecker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';


const String currentVersion = '1.0.6'; // Update with your app's version

Future<void> autoUpdateWebApp() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    DocumentSnapshot snapshot = await _firestore.collection('appVersions').doc('latest').get();
    if (snapshot.exists) {
      String latestVersion = snapshot['version'];
      if (latestVersion != currentVersion) {
        html.window.location.reload(); // Reload the web app only once
      }
    }
  } catch (e) {
    print('Error checking for updates: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kIsWeb) {
    await autoUpdateWebApp(); // Only run on web
   
  }
  runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
//final UpdateService _updateService = UpdateService();
  

   @override
  void initState() {
    super.initState();
   //Use context safely within a stateful widget's initState
  // WidgetsBinding.instance.addPostFrameCallback((_) {
  //    _updateService.checkForUpdates(context);
  //  });
  }

  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //UpdateService().checkForUpdates(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FKDataHub',

      builder: (context, child) {
    final mq = MediaQuery.of(context);
    // If the keyboard is open but Flutter reports a huge bottom padding,
    // clamp it so you don't get a grey gap.
    final keyboard = mq.viewInsets.bottom;
    final fixed = mq.copyWith(
      padding: mq.padding.copyWith(bottom: 0),
      viewPadding: mq.viewPadding.copyWith(bottom: 0),
      // keep the reported keyboard height (so fields can move up)
      viewInsets: mq.viewInsets.copyWith(bottom: keyboard),
    );
    return MediaQuery(data: fixed, child: child!);
  },

      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: LoadingPage(),
      //home : const AnimatedSplashScreenWidget(),
      /* builder: (context, child) {
        // Initialize version checking
        VersionChecker.startPeriodicChecks(context);
        return child!;
      },*/
    );
  }
}

class AnimatedSplashScreenWidget extends StatelessWidget {
  const AnimatedSplashScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(child: Lottie.asset('assets/loading_gif.json')),
      nextScreen: LoginScreen(),
      splashIconSize: 300,
      backgroundColor: Colors.white,
      duration: 2000,
    );
  }
}
