class Question {
  final String prompt;
  final String answer;
  final List<dynamic> options;
  String? uid;
  int? likes = 0;
  int? dislikes = 0;

  factory Question.fromMap(Map map) {
    Map nullMap = {
      "uid": null,
      "likes": 0,
      "dislikes": 0,
    };
    Map finalMap = {};
    finalMap.addAll(map);

    nullMap.forEach((key, value) {
      finalMap.putIfAbsent(key, () => value);
    });

    return Question(
      uid: finalMap["uid"],
      prompt: finalMap["prompt"],
      answer: finalMap["answer"],
      options: finalMap["options"],
      likes: finalMap["likes"],
      dislikes: finalMap["dislikes"],
    );
  }

  Question(
      {this.uid,
      required this.prompt,
      required this.answer,
      required this.options,
      this.likes,
      this.dislikes});

  Map toMap() {
    return {
      "uid": uid,
      "prompt": prompt,
      "answer": answer,
      "options": options,
      "likes": likes,
      "dislikes": dislikes,
    };
  }
}
