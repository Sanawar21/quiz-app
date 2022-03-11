import './quiz.dart';

class ReducedQuiz {
  final String? uid;
  final String name;
  final String description;
  final String createdBy;
  final int questionsAmount;
  final int likes;
  final int dislikes;

  ReducedQuiz(
      {required this.uid,
      required this.name,
      required this.description,
      required this.createdBy,
      required this.questionsAmount,
      required this.likes,
      required this.dislikes});

  factory ReducedQuiz.fromQuiz(Quiz quiz) {
    return ReducedQuiz(
      uid: quiz.uid,
      name: quiz.name,
      description: quiz.description,
      createdBy: quiz.createdBy,
      questionsAmount: quiz.questions!.length,
      likes: quiz.likes == null ? 0 : quiz.likes as int,
      dislikes: quiz.dislikes == null ? 0 : quiz.dislikes as int,
    );
  }

  factory ReducedQuiz.fromQuizMap(Map map) {
    Map nullMap = {
      "likes": 0,
      "dislikes": 0,
    };

    nullMap.forEach((key, value) {
      map.putIfAbsent(key, () => value);
    });

    return ReducedQuiz(
        uid: map["uid"],
        name: map["name"],
        description: map["description"],
        createdBy: map["createdBy"],
        questionsAmount: map["questions"].length,
        likes: map["likes"] == null ? 0 : int.parse(map["likes"]),
        dislikes: map["dislikes"] == null ? 0 : int.parse(map["dislikes"]));
  }
}
