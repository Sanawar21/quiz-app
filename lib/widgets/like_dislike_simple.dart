import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/quiz.dart';
import '../models/user.dart';

class SimpleLikeButton extends StatelessWidget {
  final Function onPressed;
  final bool isActive;

  SimpleLikeButton({required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onPressed(),
      icon: const Icon(Icons.thumb_up_sharp),
      color: isActive ? Colors.blue : Colors.black,
    );
  }
}

class SimpleDislikeButton extends StatelessWidget {
  final Function onPressed;
  final bool isActive;

  SimpleDislikeButton({required this.isActive, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onPressed(),
      icon: const Icon(Icons.thumb_down_sharp),
      color: isActive ? Colors.red : Colors.black,
    );
  }
}

class SimpleLikeDislikeColumn extends StatefulWidget {
  Function changeLikeness;
  Quiz quiz;
  QuizAppUser user;

  SimpleLikeDislikeColumn(
      {required this.quiz, required this.changeLikeness, required this.user});

  @override
  State<SimpleLikeDislikeColumn> createState() =>
      _SimpleLikeDislikeColumnState();
}

class _SimpleLikeDislikeColumnState extends State<SimpleLikeDislikeColumn> {
  late bool _likeIsActive;
  late bool _dislikeIsActive;
  late int _likeCount;
  late int _dislikeCount;

  Future<void> _changeLikenessOfLike() async {
    List<dynamic> _likeDislikeValues =
        await widget.changeLikeness(widget.quiz, "like");
    if (_likeDislikeValues == null) {
      return;
    }
    setState(() {
      _likeIsActive = _likeDislikeValues[0][0];
      _dislikeIsActive = _likeDislikeValues[1][0];
      _likeCount = _likeDislikeValues[0][1];
      _dislikeCount = _likeDislikeValues[1][1];
    });
  }

  Future<void> _changeLikenessOfDislike() async {
    List<dynamic> _likeDislikeValues =
        await widget.changeLikeness(widget.quiz, "dislike");
    if (_likeDislikeValues == null) {
      return;
    }
    setState(() {
      _likeIsActive = _likeDislikeValues[0][0];
      _dislikeIsActive = _likeDislikeValues[1][0];
      _likeCount = _likeDislikeValues[0][1];
      _dislikeCount = _likeDislikeValues[1][1];
    });
  }

  @override
  void initState() {
    super.initState();
    _dislikeIsActive = widget.user.quizzesDisliked != null &&
        widget.user.quizzesDisliked!.contains(widget.quiz.uid);
    _likeIsActive = widget.user.quizzesLiked != null &&
        widget.user.quizzesLiked!.contains(widget.quiz.uid);
    _likeCount = widget.quiz.likes as int;
    _dislikeCount = widget.quiz.dislikes as int;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(children: [
            Text(_likeCount.toString()),
            SimpleLikeButton(
                isActive: _likeIsActive, onPressed: _changeLikenessOfLike),
          ]),
        ),
        Expanded(
          child: Row(
            children: [
              Text(_dislikeCount.toString()),
              SimpleDislikeButton(
                  isActive: _dislikeIsActive,
                  onPressed: _changeLikenessOfDislike),
            ],
          ),
        ),
      ],
    );
  }
}

class SimpleLikeDislikeRow extends StatefulWidget {
  Function changeLikeness;
  Quiz quiz;
  QuizAppUser user;

  SimpleLikeDislikeRow(
      {required this.quiz, required this.changeLikeness, required this.user});

  @override
  State<SimpleLikeDislikeRow> createState() => _SimpleLikeDislikeRowState();
}

class _SimpleLikeDislikeRowState extends State<SimpleLikeDislikeRow> {
  late bool _likeIsActive;
  late bool _dislikeIsActive;
  late int _likeCount;
  late int _dislikeCount;

  Future<void> _changeLikenessOfLike() async {
    List<dynamic> _likeDislikeValues =
        await widget.changeLikeness(widget.quiz, "like");
    if (_likeDislikeValues == null) {
      return;
    }
    setState(() {
      _likeIsActive = _likeDislikeValues[0][0];
      _dislikeIsActive = _likeDislikeValues[1][0];
      _likeCount = _likeDislikeValues[0][1];
      _dislikeCount = _likeDislikeValues[1][1];
    });
  }

  Future<void> _changeLikenessOfDislike() async {
    List<dynamic> _likeDislikeValues =
        await widget.changeLikeness(widget.quiz, "dislike");
    if (_likeDislikeValues == null) {
      return;
    }
    setState(() {
      _likeIsActive = _likeDislikeValues[0][0];
      _dislikeIsActive = _likeDislikeValues[1][0];
      _likeCount = _likeDislikeValues[0][1];
      _dislikeCount = _likeDislikeValues[1][1];
    });
  }

  @override
  void initState() {
    super.initState();
    _dislikeIsActive = widget.user.quizzesDisliked != null &&
        widget.user.quizzesDisliked!.contains(widget.quiz.uid);
    _likeIsActive = widget.user.quizzesLiked != null &&
        widget.user.quizzesLiked!.contains(widget.quiz.uid);
    _likeCount = widget.quiz.likes as int;
    _dislikeCount = widget.quiz.dislikes as int;
  }

  @override
  Widget build(BuildContext context) {
    _dislikeIsActive = widget.user.quizzesDisliked != null &&
        widget.user.quizzesDisliked!.contains(widget.quiz.uid);
    _likeIsActive = widget.user.quizzesLiked != null &&
        widget.user.quizzesLiked!.contains(widget.quiz.uid);
    _likeCount = widget.quiz.likes as int;
    _dislikeCount = widget.quiz.dislikes as int;

    return Row(
      children: [
        Expanded(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_likeCount.toString()),
            SimpleLikeButton(
                isActive: _likeIsActive, onPressed: _changeLikenessOfLike),
          ]),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_dislikeCount.toString()),
              SimpleDislikeButton(
                  isActive: _dislikeIsActive,
                  onPressed: _changeLikenessOfDislike),
            ],
          ),
        ),
      ],
    );
  }
}

class SimpleQuestionLikeDislikeRow extends StatefulWidget {
  Function changeLikeness;
  Question question;
  QuizAppUser user;

  SimpleQuestionLikeDislikeRow(
      {required this.question,
      required this.changeLikeness,
      required this.user});

  @override
  State<SimpleQuestionLikeDislikeRow> createState() =>
      _SimpleQuestionLikeDislikeRowState();
}

class _SimpleQuestionLikeDislikeRowState
    extends State<SimpleQuestionLikeDislikeRow> {
  late bool _likeIsActive;
  late bool _dislikeIsActive;
  late int _likeCount;
  late int _dislikeCount;
  late Widget likeButton;
  late Widget dislikeButton;

  Future<void> _changeLikenessOfLike() async {
    List<dynamic> _likeDislikeValues =
        await widget.changeLikeness(widget.question, "like");
    if (_likeDislikeValues == null) {
      return;
    }
    setState(() {
      _likeIsActive = _likeDislikeValues[0][0];
      _dislikeIsActive = _likeDislikeValues[1][0];
      _likeCount = _likeDislikeValues[0][1];
      _dislikeCount = _likeDislikeValues[1][1];
    });
  }

  Future<void> _changeLikenessOfDislike() async {
    List<dynamic> _likeDislikeValues =
        await widget.changeLikeness(widget.question, "dislike");
    if (_likeDislikeValues == null) {
      return;
    }
    setState(() {
      _likeIsActive = _likeDislikeValues[0][0];
      _dislikeIsActive = _likeDislikeValues[1][0];
      _likeCount = _likeDislikeValues[0][1];
      _dislikeCount = _likeDislikeValues[1][1];
    });
  }

  void reload() {
    setState(() {
      _dislikeIsActive = widget.user.questionsDisliked != null &&
          widget.user.questionsDisliked!.contains(widget.question.uid);
      _likeIsActive = widget.user.questionsLiked != null &&
          widget.user.questionsLiked!.contains(widget.question.uid);
      _likeCount = widget.question.likes as int;
      _dislikeCount = widget.question.dislikes as int;
      likeButton = SimpleLikeButton(
          isActive: _likeIsActive, onPressed: _changeLikenessOfLike);
      dislikeButton = SimpleDislikeButton(
          isActive: _dislikeIsActive, onPressed: _changeLikenessOfDislike);
    });
    // setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _dislikeIsActive = widget.user.questionsDisliked != null &&
        widget.user.questionsDisliked!.contains(widget.question.uid);
    _likeIsActive = widget.user.questionsLiked != null &&
        widget.user.questionsLiked!.contains(widget.question.uid);
    _likeCount = widget.question.likes as int;
    _dislikeCount = widget.question.dislikes as int;
    likeButton = SimpleLikeButton(
        isActive: _likeIsActive, onPressed: _changeLikenessOfLike);
    dislikeButton = SimpleDislikeButton(
        isActive: _dislikeIsActive, onPressed: _changeLikenessOfDislike);
  }

  @override
  Widget build(BuildContext context) {
    reload();
    return Row(
      children: [
        Expanded(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(_likeCount.toString()), likeButton]),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(_dislikeCount.toString()), dislikeButton],
          ),
        ),
      ],
    );
  }
}
