import 'package:flutter/material.dart';

import '../backend/authenticate.dart';
import '../backend/database.dart' as database;

import '../models/quiz.dart';
import '../models/user.dart';

import '../widgets/quiz_list_tile.dart';

class ProfilePage extends StatefulWidget {
  final Function _changePage;
  bool instantReturn;

  ProfilePage(this._changePage, {this.instantReturn = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

  AppBar appbar(BuildContext context) {
    return AppBar(
      actions: [
        TextButton.icon(
            label: const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              await logout(context);
              // Navigator.pushReplacement(context,
              //     MaterialPageRoute(builder: ((context) => LoginPage())));
            },
            icon: Icon(Icons.person_off))
      ],
      title: const Text("Profile"),
    );
  }
}

class _ProfilePageState extends State<ProfilePage> {
  var _currentUserData;
  var _futureOwnQuizzes;
  var _futureLikedQuizzes;

  Future<List<Object>?> _changeLikeness(Quiz quiz, String of) async {
    QuizAppUser user = QuizAppUser.fromMap(await _currentUserData);
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

  getcurrentUserData() async {
    return database.fetchCurrentUserData();
  }

  @override
  void initState() {
    super.initState();
    _currentUserData = getcurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _currentUserData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          dynamic data = snapshot.data;
          QuizAppUser user = QuizAppUser.fromMap(data);
          _futureLikedQuizzes = database.getLikedQuizzes(user);
          _futureOwnQuizzes = database.getOwnQuizzes(user);
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Column(children: [
                Text(
                  database.loggedInUser!.displayName as String,
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.quizzes!.length.toString(),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Text("Quizzes",
                            style: Theme.of(context).textTheme.headline6),
                      ],
                    )),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.followers!.length.toString(),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Text("Followers",
                            style: Theme.of(context).textTheme.headline6),
                      ],
                    )),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        var followers = database.getFollowersNames();

                        showGeneralDialog(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return Container(
                              child: Column(
                                children: [
                                  Text("l"),
                                  Text('2'),
                                  // IconButton(
                                  //   icon: Icon(Icons.close),
                                  //   onPressed: () =>
                                  //       Navigator.of(context).pop(),
                                  // ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.end,
                                  //   children: [
                                  //     Container(
                                  //       child: IconButton(
                                  //         icon: Icon(Icons.close),
                                  //         onPressed: () =>
                                  //             Navigator.of(context).pop(),
                                  //       ),
                                  //     )
                                  //   ],
                                  // )
                                ],
                              ),
                            );
                          },
                          context: context,
                          // builder: (context) {
                          //   return Container(

                          //   );
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.accountsFollowed!.length.toString(),
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text("Following",
                              style: Theme.of(context).textTheme.headline6),
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Quizzes Created",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Container(
                      color: Theme.of(context).focusColor,
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: double.infinity,
                      child: FutureBuilder(
                        future: _futureOwnQuizzes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            List<Quiz> quizList = snapshot.data as List<Quiz>;
                            return ListView.builder(
                                itemCount: quizList.length,
                                itemBuilder: ((context, index) {
                                  if (quizList.isEmpty) {
                                    return const Expanded(
                                        child: Text("No quizzes created yet."));
                                  }
                                  return QuizListTile(
                                    quizList[index],
                                    _changeLikeness,
                                    user,
                                    widget._changePage,
                                    () {},
                                    pop: true,
                                  );
                                }));
                          } else if (snapshot.hasError) {
                            return Container();
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      width: double.infinity,
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Quizzes Liked",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Container(
                      color: Theme.of(context).colorScheme.secondary,
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: FutureBuilder(
                        future: _futureLikedQuizzes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            List<Quiz> quizList = snapshot.data as List<Quiz>;
                            return ListView.builder(
                                itemCount: quizList.length,
                                itemBuilder: ((context, index) {
                                  if (quizList.isEmpty) {
                                    return const Expanded(
                                        child: Text("No quizzes created yet."));
                                  }
                                  return QuizListTile(
                                    quizList[index],
                                    _changeLikeness,
                                    user,
                                    widget._changePage,
                                    () {},
                                    pop: true,
                                  );
                                }));
                          } else if (snapshot.hasError) {
                            return Container();
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    )
                  ],
                )
              ]),
            ),
          );
          // return user == null ? Container() : Container(user.displayName);
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
            child: CircularProgressIndicator.adaptive(),
          );
        }
      },
    );
  }
}
