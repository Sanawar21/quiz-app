import 'package:flutter/material.dart';
import '../pages/homepage.dart';

import '../models/quiz.dart';

import '../widgets/play_quiz.dart';
import '../widgets/quiz_selection.dart';

class PlayQuizPage extends StatefulWidget {
  Quiz? quiz;
  final Function _changePage;

  AppBar appbar(BuildContext context) {
    return AppBar(
      title: const Text("Play Quiz"),
    );
  }

  PlayQuizPage(this._changePage, {this.quiz});

  @override
  State<PlayQuizPage> createState() => _PlayQuizPageState();
}

class _PlayQuizPageState extends State<PlayQuizPage> {
  void goHome() {
    widget._changePage(HOME_PAGE);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 70,
      // child: Expanded(
      child: widget.quiz == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "No quiz selected.",
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 40),
                ),
                TextButton(
                    onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: ((context) {
                          return QuizSelection(widget._changePage);
                        }))),
                    child: Text("Select a quiz."))
              ],
            )
          : PlayQuiz(widget.quiz as Quiz, goHome, widget._changePage),
    );
  }
}
