import 'package:flutter/material.dart';

import '../models/question.dart';
import './message_dialog.dart';

class AddQuestionModalSheet extends StatefulWidget {
  final Function addQuestion;

  AddQuestionModalSheet(this.addQuestion);

  @override
  _AddQuestionModalSheetState createState() => _AddQuestionModalSheetState();
}

class _AddQuestionModalSheetState extends State<AddQuestionModalSheet> {
  final promptField = TextEditingController();
  final optionField = TextEditingController();
  final correctOptionField = TextEditingController();
  final _scrollController = ScrollController();
  final List<String> optionsList = [];
  String correctOption = '';

  void _deleteOption(option) {
    setState(() {
      optionsList.remove(option);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Question")),
      body: Container(
        padding: EdgeInsets.all(5),
        child: Card(
          elevation: 3,
          child: Container(
            padding: const EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height * 0.9,
            child: SingleChildScrollView(
                child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    label: Text("Question"),
                  ),
                  controller: promptField,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: TextField(
                          decoration:
                              const InputDecoration(label: Text("Add Option")),
                          controller: optionField,
                          onEditingComplete: () {
                            setState(() {
                              if (optionField.text.isEmpty) {
                                return;
                              }
                              optionsList.add(optionField.text);
                              optionField.clear();
                            });
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          if (optionField.text.isEmpty) {
                            return;
                          }
                          optionsList.add(optionField.text);
                          optionField.clear();
                        });
                      },
                    ),
                  ],
                ),
                TextField(
                  decoration:
                      const InputDecoration(label: Text("Correct Answer")),
                  controller: correctOptionField,
                  onSubmitted: (input) {
                    setState(() {
                      correctOption = input;
                    });
                  },
                ),
                Padding(padding: EdgeInsets.all(8)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Added Options (${optionsList.length})"),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Card(
                        elevation: 2,
                        color: Theme.of(context).bottomAppBarColor,
                        child: Scrollbar(
                          controller: _scrollController,
                          isAlwaysShown: true,
                          thickness: 8,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: optionsList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(optionsList[index]),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteOption(optionsList[index]),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          correctOption = correctOptionField.text;
                          if (promptField.text == '' ||
                              optionsList.isEmpty ||
                              correctOption == '') {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return MessageDialogPopUp(
                                      "No fields can be left empty.");
                                });
                            return;
                          } else if (!optionsList.contains(correctOption)) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return MessageDialogPopUp(
                                      "The correct answer is not in the given options.");
                                });
                            return;
                          }
                          widget.addQuestion(Question(
                              prompt: promptField.text,
                              options: optionsList,
                              answer: correctOption));
                        },
                        child: Text("Add Question.")),
                  ],
                ),
              ],
            )),
          ),
        ),
        // ),
      ),
    );
  }
}
