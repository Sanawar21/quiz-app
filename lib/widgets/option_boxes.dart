import 'package:flutter/material.dart';
import '../models/question.dart';

final BoxDecoration idleBoxDecoration =
    BoxDecoration(border: Border.all(width: 1));

final BoxDecoration correctAnswerDecoration = BoxDecoration(
    border: Border.all(width: 1), color: Colors.greenAccent.shade200);

final BoxDecoration correctChoosenDecoration = BoxDecoration(
    border: Border.all(width: 1), color: Colors.greenAccent.shade200);

final BoxDecoration choosenOptionDecoration = BoxDecoration(
    border: Border.all(width: 1), color: Colors.redAccent.shade200);

class PreAnswerOptionBox extends StatelessWidget {
  List options;
  Function onOptionChoosen;
  Question question;

  PreAnswerOptionBox(this.options, this.onOptionChoosen, this.question,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      height: MediaQuery.of(context).size.height * 0.4,
      child: ListView(
          children: options.map((option) {
        return Container(
          padding: const EdgeInsets.all(2.0),
          decoration: idleBoxDecoration,
          width: double.infinity,
          margin: EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
          // color: Theme.of(context).colorScheme.onSecondaryContainer,
          child: TextButton(
            onPressed: () => onOptionChoosen(option, question),
            child: Text(
              option,
            ),
            style: Theme.of(context).textButtonTheme.style,
          ),
        );
      }).toList()),
    );
  }
}

class PostAnswerOptionBox extends StatelessWidget {
  final String choosenOption;
  final Question question;

  const PostAnswerOptionBox(this.choosenOption, this.question, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int choosenOptionIndex = question.options.indexOf(choosenOption);
    int answerIndex = question.options.indexOf(question.answer);
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      height: MediaQuery.of(context).size.height * 0.4,
      child: ListView.builder(
          itemCount: question.options.length,
          itemBuilder: ((context, index) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(2.0),
              decoration: index == choosenOptionIndex && index == answerIndex
                  ? correctChoosenDecoration
                  : index == choosenOptionIndex
                      ? choosenOptionDecoration
                      : index == answerIndex
                          ? correctAnswerDecoration
                          : idleBoxDecoration,
              width: double.infinity,
              margin: EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
              // color: Theme.of(context).colorScheme.onSecondaryContainer,
              child: TextButton(
                child: Text(
                  question.options[index],
                  style: TextStyle(color: Colors.black),
                ),
                style: Theme.of(context).textButtonTheme.style?.copyWith(),
                onPressed: () {},
              ),
            );
          })),
    );
  }
}
