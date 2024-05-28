import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studysakha_callCenter/user_data/user_data.dart';


class CallHistory extends StatefulWidget {
  const CallHistory({Key? key}) : super(key: key);

  @override
  State<CallHistory> createState() => _CallHistoryState();
}

class _CallHistoryState extends State<CallHistory> {
  DocumentReference expertDocRef =
                FirebaseFirestore.instance.collection('experts').doc(FirebaseAuth.instance.currentUser?.uid);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const UserData(),
            const SizedBox(height: 50.0),
            const Padding(
              padding: EdgeInsets.only(left: 18.0, bottom: 7.0),
              child: Text("History", style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20.0,
                color: Colors.grey
              )),
            ),
            const SizedBox(height: 30.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: expertDocRef.collection('call_history').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<QueryDocumentSnapshot> callHistoryDocs = snapshot.data!.docs;

                          List<Widget> callHistoryWidgets = callHistoryDocs.map((doc) {
                            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                            String callerName = data['caller_name'];
                            String duration = data['duration'].toString();

                            // Call your custom widget
                            return callDetails(callerName, duration);
                          }).toList();

                          return Column(
                            children: callHistoryWidgets,
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ),
    );
  }
  Widget callDetails(String name, String duration)
  {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Image.asset('assets/Arrow 1.png'),
            ),
            const SizedBox(width: 10),
            Text(name, style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16
            )),
            const Spacer(),
            Text("$duration mins", style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            )),
            const SizedBox(width: 15.0)
          ],
        ),
        const SizedBox(height: 30.0)
      ],
    );
  }
}
