import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class UserData extends StatefulWidget {
  const UserData({Key? key}) : super(key: key);

  @override
  State<UserData> createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {

  bool available = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAvailable();
  }
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> getAvailable() async
  {
    DocumentReference documentReference = FirebaseFirestore.instance.collection('experts').doc(user?.uid);
    DocumentSnapshot snapshot = await documentReference.get();
    setState(() {
      available = snapshot['available'];
    });
  }

  Future<void> change() async
  {
    setState(() {
      available == true ? available = false : available = true;
    });
    if(available == true)
    {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print(fcmToken);
    }
    DocumentReference documentReference = FirebaseFirestore.instance.collection('experts').doc(user?.uid);
    await documentReference.update({
      'available': available,
    });
  }



  @override
  Widget build(BuildContext context) {
    String? name = user?.displayName;
    String? photoUrl = user?.photoURL;
    name = name!.split(' ')[0];
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20.0),
      child: Row(
        children: <Widget>[
          // InkWell(
          //     onTap: ()
          //     async {
          //         await GoogleSignIn().disconnect();
          //         FirebaseAuth.instance.signOut();
          //     },
          //     child: Image.asset("assets/Ellipse 156.png")),
          CircleAvatar(
            backgroundImage: NetworkImage(photoUrl!),
            radius: 25,
          ),
          const SizedBox(width: 8),
          Text("Hi $name!", style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22
          )),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 37.5,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: available == true ? const Color(0xFF45CE04) : const Color(0xFFFF2D2D),
                    ),
                    child: available == true ? Image.asset('assets/Vector.png') : Image.asset('assets/Vector1.png'),
                  ),
                  InkWell(
                    child: Container(
                      height: 30.0,
                      width: 37.5,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(4.0), bottomRight: Radius.circular(4.0)),
                        color: Color(0xFFECEAEA),
                      ),
                    ),
                    onTap: ()
                    {
                      change();
                    },
                  )
                ],
              ),
              const SizedBox(height: 10.0),
              Container(
                  width: 131,
                  height: 30,
                  decoration: BoxDecoration(
                      color: available == true ? const Color(0x4F73FE92) : const Color(0x4FFD5F5F),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        topLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Center(
                      child: available == true ? const Text("Now learners will be able to connect with you.", style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 8.0,
                          color: Color(0xFF028307)
                      )) : const Text("Now learners won't be able to connect with you.", style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 8.0,
                          color: Color(0xFFE90505)
                      )) ,
                    ),
                  )
              )
            ],
          ),
        ],
      ),
    );
  }
}