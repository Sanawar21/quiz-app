class QuizAppUser {
  final String uid;
  final String displayName;
  List<dynamic>? accountsFollowed = [];
  List<dynamic>? followers = [];
  List<dynamic>? quizzes = [];
  List<dynamic>? quizzesLiked = [];
  List<dynamic>? comments = [];
  List<dynamic>? questionsLiked = [];
  List<dynamic>? questionsDisliked = [];
  List<dynamic>? quizzesDisliked = [];

  QuizAppUser(
      {required this.uid,
      required this.displayName,
      this.accountsFollowed,
      this.followers,
      this.quizzes,
      this.quizzesLiked,
      this.quizzesDisliked,
      this.comments,
      this.questionsLiked,
      this.questionsDisliked});

  factory QuizAppUser.newUser(String uid, String displayName) {
    return QuizAppUser(uid: uid, displayName: displayName);
  }

  factory QuizAppUser.fromMap(Map map) {
    Map nullMap = {
      "quizzes": [],
      "quizzesLiked": [],
      "quizzesDisliked": [],
      "comments": [],
      "questionsLiked": [],
      "questionsDisliked": [],
      "accountsFollowed": [],
      "followers": [],
    };
    Map finalMap = {};
    finalMap.addAll(map);

    nullMap.forEach((key, value) {
      finalMap.putIfAbsent(key, () => value);
    });

    return QuizAppUser(
      uid: finalMap["uid"],
      displayName: finalMap["displayName"],
      quizzes: finalMap["quizzes"],
      quizzesLiked: finalMap["quizzesLiked"],
      quizzesDisliked: finalMap["quizzesDisliked"],
      comments: finalMap["comments"],
      questionsLiked: finalMap["questionsLiked"],
      accountsFollowed: finalMap["accountsFollowed"],
      questionsDisliked: finalMap["questionsDisliked"],
      followers: finalMap["followers"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'quizzes': quizzes,
      'quizzesLiked': quizzesLiked,
      'quizzesDisliked': quizzesDisliked,
      'accountsFollowed': accountsFollowed,
      'followers': followers,
      'comments': comments,
      'questionsLiked': questionsLiked,
      'questionsDisliked': questionsDisliked,
    };
  }
}
