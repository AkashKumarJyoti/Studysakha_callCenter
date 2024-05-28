import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:studysakha_callCenter/user_data/navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Notification/call_notification.dart';
import 'authentication/google_signIn.dart';
import 'call_page/call_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env');
  await FirebaseMessaging.instance.getInitialMessage();
  await FirebaseApiInterface().initNotifications();

  runApp(const MainApp());
  // DependencyInjection.init();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    const secondaryColor = Color(0xff6D28D9);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Studysakha',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        shadowColor: secondaryColor,
      ),
      home: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  String? name;

  Future<void> initializeApp() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      name = userCredential.user?.displayName;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyNavigationBar(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthPage())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFF81C784),
              Color(0xFFC8E6C9),
              Color(0xFF69F0AE)
            ]),
          ),
          child: const Center(
            child: Text(
              "StudySakha",
              style: TextStyle(
                color: Color(0xFF43A047),
                fontSize: 38,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}