import 'package:flutter/material.dart';
import '../models/quiz.dart';

import '../backend/database.dart' as database;

import '../pages/homepage.dart';
import '../pages/quiz_list_page.dart';

class QuizSelection extends StatefulWidget {
  Function changePage;

  QuizSelection(this.changePage, {Key? key}) : super(key: key);

  @override
  State<QuizSelection> createState() => _QuizSelectionState();
}

class _QuizSelectionState extends State<QuizSelection> {
  void onListTileClicked(Quiz quiz) {
    widget.changePage(PLAY_QUIZ_PAGE, quiz: quiz);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select a quiz")),
      body: QuizListPage(
        widget.changePage,
        onTileClicked: onListTileClicked,
      ),
    );
  }
}
