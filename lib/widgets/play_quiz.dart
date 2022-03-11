import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/like_dislike_simple.dart';

import '../models/quiz.dart';
import '../models/question.dart';

import '../widgets/option_boxes.dart';

import '../backend/database.dart' as database;
import './quiz_selection.dart';

class PlayQuiz extends StatefulWidget {
  final Quiz quiz;
  final Function goHome;
  final Function changePage;
  PlayQuiz(this.quiz, this.goHome, this.changePage);

  @override
  _PlayQuizState createState() => _PlayQuizState(quiz);
}

class _PlayQuizState extends State<PlayQuiz> {
  Quiz quiz;
  int iteration = -1;
  late Future<List<Question>?> _questions;
  bool isOptionChoosen = false;
  late String choosenOption;
  var _futureData;

  var _score = 0;
  _PlayQuizState(this.quiz);

  Future<List<Question>?> questionsGetter() async {
    List<Question> questions = [];
    if (quiz.questions == null) {
      return null;
    } else {
      for (var questionUid in quiz.questions!) {
        Question question = await database.getQuestion(questionUid) as Question;
        questions.add(question);
      }
    }
    return questions;
  }

  Future<QuizAppUser?> get _currentUser async {
    final userData = await database.fetchCurrentUserData();
    if (userData == null) {
      return null;
    }
    return QuizAppUser.fromMap(userData);
  }

  Future<List<Object>?> _changeLikenessOfQuestion(
      Question question, String of) async {
    try {
      QuizAppUser? user = await _currentUser;
      if (user == null) {
        return null;
      }

      if (of == "like") {
        if (user.questionsLiked!.contains(question.uid)) {
          // already liked so remove like
          await database.removeQuestionLikeFromAll(question.uid as String);
          user.questionsLiked!.remove(question.uid);
          question.likes = question.likes! - 1;
        } else {
          // add like
          if (user.questionsDisliked!.contains(question.uid)) {
            // remove quiz from disliked
            await database.removeQuestionDislikeFromAll(question.uid as String);
            user.questionsDisliked!.remove(question.uid);
            question.dislikes = question.dislikes! - 1;
          }
          await database.addQuestionLikeToAll(question.uid as String);
          user.questionsLiked!.add(question.uid);
          question.likes = question.likes! + 1;
        }
      } else {
        if (user.questionsDisliked!.contains(question.uid)) {
          // already disliked so remove dislike
          await database.removeQuestionDislikeFromAll(question.uid as String);
          user.questionsDisliked!.remove(question.uid);
          question.dislikes = question.dislikes! - 1;
        } else if (of == "dislike") {
          if (user.questionsLiked!.contains(question.uid)) {
            // remove like and dislike
            await database.removeQuestionLikeFromAll(question.uid as String);
            user.questionsLiked!.remove(question.uid);
            question.likes = question.likes! - 1;
          }
          await database.addQuestionDisLikeToAll(question.uid as String);
          user.questionsDisliked!.add(question.uid);
          question.dislikes = question.dislikes! + 1;
        } else {}
      }

      final bool _likeIsActive = user.questionsLiked!.contains(question.uid);
      final bool _dislikeIsActive =
          user.questionsDisliked!.contains(question.uid);

      return [
        [_likeIsActive, question.likes],
        [_dislikeIsActive, question.dislikes],
      ];
    } catch (e) {
      return null;
    }
  }

  void _onOptionChoosen(String option, Question question) {
    setState(() {
      isOptionChoosen = true;
      if (question.answer == option) {
        _score++;
      }
      choosenOption = option;
    });
  }

  Future<List<dynamic>?> questionsListAndUser() async {
    try {
      final user = await _currentUser;
      final questions = await questionsGetter();
      return [user, questions];
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _futureData = questionsListAndUser();
  }

  @override
  Widget build(BuildContext context) {
    var totalQuestions = quiz.questions!.length;
    return FutureBuilder(
      future: _futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          dynamic data = snapshot.data;
          List<Question> questions = data[1] as List<Question>;
          QuizAppUser user = data[0] as QuizAppUser;
          if (iteration == -1) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    quiz.name,
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontSize: 35),
                  ),
                  Padding(padding: EdgeInsets.all(8)),
                  Text(
                    "Created by: ${quiz.createdBy}",
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontSize: 20),
                  ),
                  Padding(padding: EdgeInsets.all(8)),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          iteration++;
                        });
                      },
                      child: Text("Start Quiz")),
                  Padding(padding: EdgeInsets.all(8)),
                  TextButton(
                      onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: ((context) {
                            return QuizSelection(widget.changePage);
                          }))),
                      child: Text("Select another quiz"))
                ],
              ),
            );
          } else if (totalQuestions != iteration) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Container(
                      color: Theme.of(context).bottomAppBarColor,
                      alignment: Alignment.topCenter,
                      // height: 30,
                      child: Text(
                        quiz.name,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontSize: 20),
                      )),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    width: double.infinity,
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Q.${iteration + 1} ${questions[iteration].prompt}",
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                      ),
                    ),
                  ),
                  isOptionChoosen
                      ? Container(
                          width: double.infinity,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              setState(() {
                                isOptionChoosen = false;
                                iteration++;
                              });
                            },
                          ),
                        )
                      : const SizedBox(
                          height: 50,
                        ),
                  isOptionChoosen
                      ? PostAnswerOptionBox(choosenOption, questions[iteration])
                      : PreAnswerOptionBox(questions[iteration].options,
                          _onOptionChoosen, questions[iteration]),
                  SimpleQuestionLikeDislikeRow(
                      question: questions[iteration],
                      changeLikeness: _changeLikenessOfQuestion,
                      user: user),
                ],
              ),
            );
          } else {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Quiz completed!.",
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontSize: 35),
                  ),
                  Text(
                    "You scored $_score/$totalQuestions.",
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontSize: 30),
                  ),
                  TextButton(
                      onPressed: () {
                        widget.goHome();
                      },
                      child: Text("Go to home page"))
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("Something went wrong."),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
