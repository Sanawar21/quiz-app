import 'package:flutter/material.dart';

import '../models/quiz.dart';

import './add_quiz.dart';
import './play_quiz.dart';
import './profile.dart';
import './quiz_list_page.dart';

const int HOME_PAGE = 0;
const int ADD_QUIZ_PAGE = 1;
const int PLAY_QUIZ_PAGE = 2;
const int PROFILE_PAGE = 3;

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Quiz? _quiz;
  void changePage(index, {Quiz? quiz}) {
    if (quiz != null && index == PLAY_QUIZ_PAGE) {
      setState(() {
        _quiz = quiz;
        _index = PLAY_QUIZ_PAGE;
      });
    } else if (index == HOME_PAGE) {
      setState(() {
        _index = HOME_PAGE;
        QuizListPage(
          changePage,
          isCalledFirstTime: false,
        );
      });
    } else {
      setState(() {
        _index = index;
      });
    }
  }

  int _index = 0;
  final String _titleText = 'Home Page';
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> screens = [
      QuizListPage(
        changePage,
        isCalledFirstTime: false,
      ),
      AddQuizPage(changePage),
      PlayQuizPage(changePage, quiz: _quiz),
      ProfilePage(changePage),
    ];

    return Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: Theme.of(context).navigationBarTheme,
        child: NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(icon: Icon(Icons.add), label: "Add Quiz"),
            NavigationDestination(
                icon: Icon(Icons.play_arrow), label: "Play Quiz"),
            NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
          ],
          selectedIndex: _index,
          onDestinationSelected: (index) {
            setState(() {
              _index = index;
            });
          },
        ),
      ),
      appBar: screens[_index].appbar(context),
      body: screens[_index],
    );
  }
}
