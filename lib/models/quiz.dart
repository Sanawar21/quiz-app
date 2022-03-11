class Quiz {
  String? uid;
  final String name;
  final String description;
  final String createdBy;
  List<dynamic>? comments;
  List<dynamic>? questions;
  int? likes;
  int? dislikes;

  Quiz(
      {this.uid,
      required this.name,
      required this.description,
      required this.createdBy,
      this.comments,
      this.questions,
      this.likes,
      this.dislikes});

  factory Quiz.fromMap(Map map) {
    Map nullMap = {
      "uid": null,
      "dislikes": 0,
      "likes": 0,
      "comments": [],
    };
    Map finalMap = {};
    finalMap.addAll(map);

    nullMap.forEach((key, value) {
      finalMap.putIfAbsent(key, () => value);
    });

    return Quiz(
      uid: finalMap["uid"],
      createdBy: finalMap["createdBy"],
      description: finalMap["description"],
      name: finalMap["name"],
      questions: finalMap["questions"],
      comments: finalMap["comments"],
      dislikes: finalMap["dislikes"],
      likes: finalMap["likes"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'comments': comments,
      'questions': questions,
      'likes': likes,
      'dislikes': dislikes
    };
  }
}
