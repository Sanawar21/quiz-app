import 'package:flutter/material.dart';
import '../pages/homepage.dart';
import '../widgets/comment_display.dart';

import '../models/comment.dart';
import '../models/quiz.dart';
import '../models/user.dart';

import './like_dislike_simple.dart';

import '../backend/authenticate.dart';
import '../backend/database.dart' as database;

class QuizPopUp extends StatefulWidget {
  final Quiz quiz;
  final Function likeOrDislikeFunction;
  final QuizAppUser user;
  final Function changePage;
  bool pop;
  QuizPopUp(this.quiz, this.likeOrDislikeFunction, this.user, this.changePage,
      {this.pop = false});

  @override
  State<QuizPopUp> createState() => _QuizPopUpState();
}

class _QuizPopUpState extends State<QuizPopUp> {
  final addCommentController = TextEditingController();
  final commentsScroll = ScrollController();
  // late Quiz quiz;
  var comments;
  bool commentsAreLoading = false;

  Future<List<Comment>> get commentsGetter async {
    return await database.getQuizComments(
        widget.quiz.uid as String, widget.quiz.comments as List);
  }

  Future<bool> _addComment(String body) async {
    try {
      Comment comment = Comment(body: body, postedBy: widget.user.displayName);
      final String? commentUid = await database.addComment(comment);
      setState(() {
        widget.quiz.comments?.add(commentUid);
      });
      return await database.addCommentToUserAndQuiz(
          commentUid!, widget.quiz.uid as String);
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeComment(String uid) async {
    try {
      widget.quiz.comments?.remove(uid);
      await database.removeCommentfromAll(uid, widget.quiz.uid as String);
      return true;
    } catch (e) {
      return false;
    }
  }

  onDeletePressed(Comment comment) async {
    setState(() {
      commentsAreLoading = true;
    });
    bool didRemove = await removeComment(comment.uid as String);
    if (didRemove) {
      setState(() {
        comments = commentsGetter;
        commentsAreLoading = false;
      });
    }
  }

  changeFollowStatus() async {
    String creatorUid =
        widget.quiz.uid!.substring(0, widget.quiz.uid!.length - 5);

    bool isFollowed = widget.user.accountsFollowed!.contains(creatorUid);

    if (isFollowed) {
      await database.unfollowAccount(creatorUid);
      setState(() {
        widget.user.accountsFollowed?.remove(creatorUid);
      });
    } else {
      await database.followAccount(creatorUid);
      setState(() {
        widget.user.accountsFollowed?.add(creatorUid);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    comments = commentsGetter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => refresh(context),
          ),
          title: Text("View Quiz"),
          actions: [
            // IconButton(
            //   onPressed: () {
            //     widget.changePage(PLAY_QUIZ_PAGE, quiz: widget.quiz);
            //     Navigator.of(context).pop();
            //   },
            //   icon: const Icon(Icons.play_arrow),
            // ),
            TextButton.icon(
                onPressed: () {
                  widget.changePage(PLAY_QUIZ_PAGE, quiz: widget.quiz);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  "Play Quiz",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Theme.of(context).bottomAppBarColor,
              alignment: Alignment.topCenter,
              child: Column(children: [
                Text(
                  widget.quiz.name,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontSize: 35),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.quiz.description,
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 10),
                widget.quiz.questions!.length == 1
                    ? Text(
                        "1 Question.",
                        style: Theme.of(context).textTheme.bodyText2,
                      )
                    : Text(
                        "${widget.quiz.questions!.length} Questions.",
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Created by: ${widget.quiz.createdBy}",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    widget.quiz.uid!.contains(widget.user.uid)
                        ? Container()
                        : TextButton(
                            onPressed: () => changeFollowStatus(),
                            child: widget.user.accountsFollowed!.contains(widget
                                    .quiz.uid!
                                    .substring(0, widget.quiz.uid!.length - 5))
                                ? const Text(
                                    "Followed",
                                    style: TextStyle(color: Colors.blue),
                                  )
                                : const Text("Follow")),
                  ],
                ),
                SimpleLikeDislikeRow(
                    quiz: widget.quiz,
                    changeLikeness: widget.likeOrDislikeFunction,
                    user: widget.user),
                const SizedBox(height: 10),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.all(8),
                  child: Card(
                    elevation: 6,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                maxLength: 100,
                                decoration: const InputDecoration(
                                    label: Text("Add a comment.")),
                                controller: addCommentController,
                                onSubmitted: (input) async {
                                  String comment = input;
                                  if (comment == '') {
                                    return;
                                  }

                                  await _addComment(comment);
                                  setState(() {
                                    comments = commentsGetter;
                                  });

                                  addCommentController.clear();
                                },
                              ),
                            ),
                            IconButton(
                                onPressed: () async {
                                  String comment = addCommentController.text;
                                  if (comment == '') {
                                    return;
                                  }
                                  await _addComment(comment);
                                  setState(() {
                                    comments = commentsGetter;
                                  });
                                  addCommentController.clear();
                                },
                                icon: const Icon(Icons.add))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                "Comments",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontSize: 20),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                widget.quiz.comments!.length.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder(
                        future: comments,
                        builder: ((context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text(
                              "Something went wrong.",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(
                                      color: Theme.of(context).errorColor),
                            ));
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            List<Comment> comments =
                                snapshot.data as List<Comment>;

                            return Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: ListView(
                                children: comments.map((comment) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CommentDisplay(comment,
                                        loggedInUser!.uid, onDeletePressed),
                                  );
                                }).toList(),
                              ),
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }),
                      ),
                    ]),
                  ),
                )
              ]),
            ),
          ),
        ));
  }
}

class ConfirmatoryPopUp extends StatelessWidget {
  Quiz quiz;
  Function deleteFunction;

  ConfirmatoryPopUp(this.quiz, this.deleteFunction);

  @override
  Widget build(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        deleteFunction(quiz);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    return AlertDialog(
      title: Text("Delete Quiz"),
      content: Text("Are you sure you want to delete ${quiz.name}?"),
      actions: [
        okButton,
      ],
    );
  }
}
