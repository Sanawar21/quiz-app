import 'dart:io';

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/quiz.dart';

import '../widgets/quiz_list_tile.dart';

import './add_quiz.dart';

import '../backend/database.dart' as database;

class QuizListPage extends StatefulWidget {
  final Function changePage;
  bool isCalledFirstTime;
  final Function? onTileClicked;

  QuizListPage(this.changePage,
      {this.isCalledFirstTime = true, this.onTileClicked = null});

  @override
  State<QuizListPage> createState() => _QuizListPageState();

  AppBar appbar(BuildContext context) {
    return AppBar(
      title: const Text("Quizzes"),
    );
  }
}

class _QuizListPageState extends State<QuizListPage> {
  dynamic _futureData;

  Future<List<List<Quiz>>?> get _quizList async {
    List<List<Quiz>> returnList = [];
    returnList.add(await database.getFollowingQuizzes());
    returnList.add(await database.getTopLikedQuizzes());
    return returnList;
  }

  Future<QuizAppUser?> get _currentUser async {
    final userData = await database.fetchCurrentUserData();
    if (userData == null) {
      return null;
    }
    return QuizAppUser.fromMap(userData);
  }

  Future<List<dynamic>?> _loadUserAndQuizList() async {
    try {
      if (widget.isCalledFirstTime) {
        sleep(const Duration(seconds: 5));
      }

      final user = await _currentUser;
      final quizList = await _quizList;
      return [user, quizList];
    } catch (e) {
      return null;
    }
  }

  Future<List<Object>?> _changeLikeness(Quiz quiz, String of) async {
    QuizAppUser? user = await _currentUser;
    if (user == null) {
      return null;
    }

    setState(() {
      user.quizzesLiked ??= [];
      user.quizzesDisliked ??= [];
      quiz.likes ??= 0;
      quiz.dislikes ??= 0;

      if (of == "like") {
        if (user.quizzesLiked!.contains(quiz.uid)) {
          // already liked so remove like
          database.removeQuizFromUserLiked(quiz.uid as String);
          database.removeFromQuizLikes(quiz.uid as String);
          user.quizzesLiked!.remove(quiz.uid);
          quiz.likes = quiz.likes! - 1;
        } else {
          // add like
          if (user.quizzesDisliked!.contains(quiz.uid)) {
            // remove quiz from disliked
            database.removeFromQuizDislikes(quiz.uid as String);
            database.removeQuizFromUserDisliked(quiz.uid as String);
            user.quizzesDisliked!.remove(quiz.uid);
            quiz.dislikes = quiz.dislikes! - 1;
          }
          database.addQuizToUserLiked(quiz.uid as String);
          database.addToQuizLikes(quiz.uid as String);
          user.quizzesLiked!.add(quiz.uid);
          quiz.likes = quiz.likes! + 1;
        }
      } else {
        if (user.quizzesDisliked!.contains(quiz.uid)) {
          // already disliked so remove dislike
          database.removeQuizFromUserDisliked(quiz.uid as String);
          database.removeFromQuizDislikes(quiz.uid as String);
          user.quizzesDisliked!.remove(quiz.uid);
          quiz.dislikes = quiz.dislikes! - 1;
        } else if (of == "dislike") {
          if (user.quizzesLiked!.contains(quiz.uid)) {
            // remove like and dislike
            database.removeFromQuizLikes(quiz.uid as String);
            database.removeQuizFromUserLiked(quiz.uid as String);
            user.quizzesLiked!.remove(quiz.uid);
            quiz.likes = quiz.likes! - 1;
          }
          database.addQuizToUserDisliked(quiz.uid as String);
          database.addToQuizDislikes(quiz.uid as String);
          user.quizzesDisliked!.add(quiz.uid);
          quiz.dislikes = quiz.dislikes! + 1;
        } else {}
      }
    });

    final bool _likeIsActive = user.quizzesLiked!.contains(quiz.uid);
    final bool _dislikeIsActive = user.quizzesDisliked!.contains(quiz.uid);

    return [
      [_likeIsActive, quiz.likes],
      [_dislikeIsActive, quiz.dislikes],
    ];
  }

  void _reload() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _futureData = _loadUserAndQuizList();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureData,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          dynamic data = snapshot.data;
          QuizAppUser user = data[0];
          List<Quiz>? followingQuizList = data[1][0];
          List<Quiz>? topQuizList = data[1][1];
          followingQuizList ??= [];
          topQuizList ??= [];
          ScrollController scrollController = ScrollController();

          return Scrollbar(
            isAlwaysShown: true,
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Container(
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          "Home",
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  ...followingQuizList.map((quiz) => QuizListTile(
                      quiz, _changeLikeness, user, widget.changePage, _reload)),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          "Top Quizzes",
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  ...topQuizList.map((quiz) => QuizListTile(
                      quiz, _changeLikeness, user, widget.changePage, _reload)),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                ]),
              ),
            ),
          );
          // return quizList.isNotEmpty
          //     ? Container(
          //         height: MediaQuery.of(context).size.height * 0.90,
          //         child: Card(
          //           child: ListView(
          //             children: [
          //               ...quizList
          //                   .map((quiz) => QuizListTile(
          //                         quiz,
          //                         _changeLikeness,
          //                         user,
          //                         widget.changePage,
          //                         _reload,
          //                         onClicked: widget.onTileClicked,
          //                       ))
          //                   .toList(),
          //             ],
          //           ),
          //         ),
          //       )
          //     : Container(
          //         alignment: Alignment.center,
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             Text(
          //               "No quiz created yet.",
          //               style: Theme.of(context)
          //                   .textTheme
          //                   .displayMedium
          //                   ?.copyWith(fontSize: 40),
          //             ),
          //             TextButton(
          //                 onPressed: () =>
          //                     Navigator.push(context, MaterialPageRoute(
          //                       builder: ((context) {
          //                         return AddQuizPage(widget.changePage);
          //                       }),
          //                     )),
          //                 child: Text("Create a quiz"))
          //           ],
          //         ),
          //       );
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
            "Something went wrong.",
            style: Theme.of(context)
                .textTheme
                .bodyText2
                ?.copyWith(color: Theme.of(context).errorColor),
          ));
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // },
      }),
    );
  }
}
