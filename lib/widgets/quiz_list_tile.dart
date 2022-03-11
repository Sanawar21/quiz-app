import 'package:flutter/material.dart';

import './quiz_popup.dart';
import '../models/quiz.dart';
import '../models/user.dart';

import './like_dislike_simple.dart';

import '../backend/database.dart' as database;
import '../backend/authenticate.dart';

class QuizListTile extends StatefulWidget {
  Quiz quiz;
  Function changeLikeness;
  final Function changePage;
  Function? onClicked;
  final Function reloadQuizList;
  bool pop;
  QuizAppUser user;
  QuizListTile(this.quiz, this.changeLikeness, this.user, this.changePage,
      this.reloadQuizList,
      {this.onClicked, this.pop = false});

  @override
  State<QuizListTile> createState() => _QuizListTileState();
}

class _QuizListTileState extends State<QuizListTile> {
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
    // refresh(context);
    widget.reloadQuizList();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (widget.onClicked == null) {
          Navigator.of(context).push(MaterialPageRoute(
              fullscreenDialog: false,
              builder: (context) {
                return QuizPopUp(
                  widget.quiz,
                  widget.changeLikeness,
                  widget.user,
                  widget.changePage,
                  pop: true,
                );
              }));
        } else {
          widget.onClicked!(widget.quiz);
        }
      },
      child: Card(
        elevation: 7,
        child: Container(
          padding: EdgeInsets.all(8.0),
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.quiz.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                    Text(
                      widget.quiz.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          children: [
                            Text(
                              "Posted by: ${widget.quiz.createdBy}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            widget.quiz.uid!.contains(widget.user.uid)
                                ? Container()
                                : TextButton(
                                    onPressed: () => changeFollowStatus(),
                                    child: widget.user.accountsFollowed!
                                            .contains(widget.quiz.uid!
                                                .substring(
                                                    0,
                                                    widget.quiz.uid!.length -
                                                        5))
                                        ? Text(
                                            "Followed",
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption
                                                ?.copyWith(color: Colors.blue),
                                          )
                                        : Text(
                                            "Follow",
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption
                                                ?.copyWith(color: Colors.black),
                                          )),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          widget.quiz.questions!.length == 1
                              ? "1 Question"
                              : "${widget.quiz.questions!.length.toString()} Questions",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                  // ),
                  // ),
                  // ],
                ),
              ),
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SimpleLikeDislikeColumn(
                          quiz: widget.quiz,
                          changeLikeness: widget.changeLikeness,
                          user: widget.user),
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
