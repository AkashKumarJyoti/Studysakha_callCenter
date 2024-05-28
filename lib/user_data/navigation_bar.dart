import 'package:flutter/material.dart';
import 'package:studysakha_callCenter/user_data/user_stats.dart';
import '../call_record.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar({Key? key}) : super(key: key);

  @override
  State<MyNavigationBar> createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar>{
  int _currentIndex = 0;

  void switchScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 0,
        currentIndex: _currentIndex,
        onTap: switchScreen,
        items: [
          BottomNavigationBarItem(
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: _currentIndex == 0
                      ? const LinearGradient(
                    colors: [Color(0xFF0FF7BD), Color(0xFF45B0E9)],
                  )
                      : const LinearGradient(colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFFFFFF),
                  ]),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    _currentIndex == 0 ? 'assets/home1.png' : 'assets/home2.png',
                    height: 25,
                    width: 25,
                  ),
                ),
              ),
            label: ""
          ),
          BottomNavigationBarItem(
              icon: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: _currentIndex == 1
                      ? const LinearGradient(
                    colors: [Color(0xFF0FF7BD), Color(0xFF45B0E9)],
                  )
                      : const LinearGradient(colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFFFFFFF),
                  ]),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    _currentIndex == 1 ? 'assets/history2.png' : 'assets/history1.png',
                    height: 25,
                    width: 25,
                  ),
                ),
              ),
              label: ""
          ),
        ],
      ),
    );
  }
  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const CallStats(); // Home screen
      case 1:
        return const CallHistory(); // History screen
      default:
        return const CallStats(); // Default to the home screen
    }
  }
}






