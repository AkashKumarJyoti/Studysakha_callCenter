import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studysakha_callCenter/user_data/user_data.dart';

import '../quiz_create/quiz_screen.dart';

class CallStats extends StatefulWidget {
  const CallStats({Key? key}) : super(key: key);

  @override
  State<CallStats> createState() => _CallStatsState();
}

class _CallStatsState extends State<CallStats> {

  List<String> getDaysOfWeek() {
    List<String> daysOfWeek = [];
    DateTime now = DateTime.now();
    for (int i = DateTime.monday; i <= DateTime.sunday; i++) {
      final day = now.subtract(Duration(days: now.weekday - i));
      daysOfWeek.add(DateFormat('E d').format(day));
    }
    return daysOfWeek;
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            const UserData(),
            const SizedBox(height: 6.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                  onPressed: ()
                  {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const QuizScreen()
                    ));
                  },
                  child: const Row(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(Icons.add_circle, color: Colors.white),
                    ),
                    Text("Create Quiz for students", style: TextStyle(
                      color: Colors.white,
                    ))
                  ],)),
            ),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: containers(0xFFFE3D3D, 0xFFFF8E8E, "Total Call", "12", "assets/Frame 573.png")
                  ),
                  const SizedBox(width: 19.0),
                  Expanded(
                    flex: 1,
                    child: containers(0xFF3DFE51, 0xAF99FF5A, "Talk Time", "20 mins 10 sec", 'assets/Frame 578.png')
                  )
                ],
              ),
            ),
            const SizedBox(height: 22.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: containers(0xFF3A87FA, 0xFF1BFCEE, "Remark", "12", 'assets/Frame 578.png')
                  ),
                  const SizedBox(width: 19.0),
                  Expanded(
                    flex: 1,
                    child: containers(0xFFD10FF0, 0xAFFE66EF, "Online Time", "20 mins 10 sec", 'assets/Frame 578.png')
                  )
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: getDaysOfWeek().map((day) {
                final parts = day.split(' ');
                final dayName = parts[0];
                final dayNumber = parts[1];
                final isCurrentDay = dayNumber == DateTime.now().day.toString();
                return Container(
                  width: MediaQuery.of(context).size.width/7-5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    gradient: isCurrentDay ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF24DACF),
                          Color(0xFF3CB6E9)
                        ]
                    )
                        : const LinearGradient(colors: [Color(0xFFECEAEA), Color(0xFFECEAEA)])
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: <Widget>[
                        Text(dayNumber, style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: isCurrentDay ? const Color(0xFFFFFFFF) : Colors.black
                        ),),
                        Text(dayName, style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: isCurrentDay ? const Color(0xFFFFFFFF) : Colors.black
                        ),),
                      ],
                    )
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30.0),
            Image.asset('assets/Frame 617.png'),
          ],
        )
      ),
    );
  }
  Widget containers(int c1, int c2, String title, String content, String imgUrl)
  {
    return Container(
        height: 82.0,
        width: 150.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(c1),
                Color(c2),
              ],
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 16.0
              )),
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(content, style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 14.0
                  )),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(imgUrl),
                ),
              ],
            )
          ],
        )
    );
  }
}
