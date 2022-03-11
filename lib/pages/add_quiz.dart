import 'package:flutter/material.dart';

import '../backend/database.dart' as database;

import '../models/question.dart';
import '../models/quiz.dart';
import '../widgets/add_question_sheet.dart';
import '../widgets/message_dialog.dart';

class AddQuizPage extends StatefulWidget {
  final Function _changePage;

  AddQuizPage(this._changePage);

  @override
  State<AddQuizPage> createState() => _AddQuizPageState();

  AppBar appbar(BuildContext context) {
    return AppBar(
      title: const Text("Add Quiz"),
    );
  }
}

class _AddQuizPageState extends State<AddQuizPage> {
  final nameFieldController = TextEditingController();
  final descriptionFieldController = TextEditingController();
  final List<Question> questions = [];
  bool _isLoading = false;

  Future<bool> _submitQuiz(List<Question> questions, Quiz quiz) async {
    List<String> questionsUids = [];

    for (Question question in questions) {
      final uid = await database.addQuestion(question);
      if (uid == null) {
        return false;
      }
      questionsUids.add(uid);
    }

    quiz.questions = questionsUids;
    final quizUid = await database.addQuiz(quiz);

    if (quizUid == null) {
      return false;
    }

    quiz.uid = quizUid;
    return await database.addQuizToCurrentUser(quiz);
  }

  void _addQuestion(Question question) {
    setState(() {
      Navigator.pop(context);
      questions.add(question);
    });
  }

  void _addQuestionSheet() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => AddQuestionModalSheet(_addQuestion))));
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(8),
              height: MediaQuery.of(context).size.height * 0.8,
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                // child: Card(
                //   elevation: 5,
                //   color: Theme.of(context).bottomAppBarColor,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(label: Text("Quiz Name")),
                        maxLength: 20,
                        controller: nameFieldController,
                      ),
                      TextField(
                        decoration:
                            InputDecoration(label: Text("Quiz Description")),
                        maxLength: 100,
                        controller: descriptionFieldController,
                      ),
                      questions.length == 1
                          ? Text("1 question added.")
                          : Text("${questions.length} questions added."),
                      questions.isNotEmpty
                          ? Container(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: ListView(
                                children: questions.map(
                                  (question) {
                                    return ListTile(
                                      title: Text(question.prompt),
                                      subtitle:
                                          Text("Answer: ${question.answer}"),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          setState(
                                            () => questions.remove(question),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: const TextButton(
                                onPressed: null,
                                child: Text("No question added."),
                              ),
                            ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: (() {
                                _addQuestionSheet();
                              }),
                              child: Text("Add a question"),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: (() async {
                                if (nameFieldController.text == "" ||
                                    descriptionFieldController.text == '' ||
                                    questions.isEmpty) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return MessageDialogPopUp(
                                            "No fields can be left empty.");
                                      });
                                  return;
                                } else {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);

                                  setState(
                                    () => _isLoading = true,
                                  );
                                  final bool didSubmit = await _submitQuiz(
                                      questions,
                                      Quiz(
                                          name: nameFieldController.text,
                                          description:
                                              descriptionFieldController.text,
                                          createdBy: database.loggedInUser!
                                              .displayName as String));
                                  setState(() => _isLoading = false);
                                  if (didSubmit) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return MessageDialogPopUp(
                                              "Quiz Added.");
                                        });
                                    setState(() {
                                      nameFieldController.clear();
                                      descriptionFieldController.clear();
                                      questions.clear();
                                    });
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return MessageDialogPopUp(
                                              "An error occured.");
                                        });
                                  }
                                }
                              }),
                              child: Text("Submit Quiz",
                                  style: Theme.of(context)
                                      .textTheme
                                      .button
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ),
          );
  }
}
