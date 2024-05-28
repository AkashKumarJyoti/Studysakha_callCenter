import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../user_data/navigation_bar.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final Color _cyan = const Color(0xFF64FFDA);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async
      {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: MediaQuery
              .of(context)
              .size
              .height,
          width: MediaQuery
              .of(context)
              .size
              .width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _cyan.withOpacity(0.2),
                _cyan.withOpacity(0.4),
                _cyan.withOpacity(0.6),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 80.0, left: 15.0, right: 15.0),
                child: TextButton(
                  onPressed: () => signInWithGoogle(context),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.white),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45.0),
                        // Border radius
                        side: const BorderSide(color: Colors.black,
                            width: 1.0), // Border color and width
                      ),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 23.0),
                        child: Image.asset(
                          "assets/google.png", height: 40.0, width: 40.0,),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 18.0),
                        child: Center(
                          child: Text("Continue with Google", style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 20
                          )),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  signInWithGoogle(BuildContext context) async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = userCredential.user;
    String? name = user?.displayName;
    CollectionReference experts = FirebaseFirestore.instance.collection('experts');
    DocumentSnapshot expertSnapshot = await experts.doc(user?.uid).get();
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (!expertSnapshot.exists) {
      DocumentReference expertDocRef = experts.doc(user?.uid);
      await expertDocRef.set({
        'displayName': name,
        'available': false,
        'user': 0,
        'message_token': fcmToken,
        'total_calls': 0,
        'talktime': 0
      });
      CollectionReference callHistoryCollection = expertDocRef.collection('call_history');
    }


    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MyNavigationBar(),
      ),
    );
  }

}


