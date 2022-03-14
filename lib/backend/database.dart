import 'dart:convert';

import 'unique_key.dart' as unique;

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';
import '../models/question.dart';
import '../models/comment.dart';
import '../models/quiz.dart';
import '../models/reduced_quiz.dart';

import './authenticate.dart' as _auth;

final DatabaseReference _database = FirebaseDatabase.instance.ref();


User? get loggedInUser {
  return _auth.loggedInUser;
}

Future<String?> addNewQuizAppUser() async {
  User? loggedInUser = FirebaseAuth.instance.currentUser;
  if (loggedInUser == null) {
    return null;
  }
  QuizAppUser newQuizAppUser =
      QuizAppUser.newUser(loggedInUser.uid, loggedInUser.displayName as String);
  final appUsersReference = _database.child('AppUsers/${loggedInUser.uid}');
  await appUsersReference.set(newQuizAppUser.toMap());
  var data = await _database.child("Usernames").get();
  List? usernames = jsonDecode(jsonEncode(data.value));
  if (usernames == null) {
    usernames = [loggedInUser.displayName];
  } else {
    usernames.add(loggedInUser.displayName);
  }
  await _database.child("Usernames").set(usernames);

  return loggedInUser.uid;
}

Future<bool> isUsernameTaken(String username) async {
  bool _return = false;
  var reference = _database.child("Usernames");
  final data = await reference.get();
  List? usernameList = jsonDecode(jsonEncode(data.value));
  usernameList ??= [];
  if (usernameList.contains(username)) {
    _return = true;
  }
  return _return;
}

Future<bool> removeCurrentUser() async {
  try {
    final userReference = _database.child('AppUsers/${loggedInUser?.uid}');
    await userReference.remove();
    await FirebaseAuth.instance.currentUser!.delete();
    return true;
  } catch (e) {
    return false;
  }
}

Future<Map?> fetchCurrentUserData() async {
  if (loggedInUser == null) {
    return null;
  }
  final appUsersReference = _database.child('AppUsers/${loggedInUser?.uid}');
  final DataSnapshot snapshot = await appUsersReference.get();
  return jsonDecode(jsonEncode(snapshot.value));
}

Future<String?> addQuestion(Question question) async {
  try {
    final uid = "${loggedInUser?.uid}${unique.key}";
    final questionsReference = _database.child('Questions/$uid');
    await questionsReference.set(question.toMap());
    return uid;
  } catch (e) {
    return null;
  }
}

Future<bool> removeQuestion(String uid) async {
  try {
    final questionReference = _database.child('Questions/$uid');
    await questionReference.remove();
    return true;
  } catch (e) {
    return false;
  }
}

Future<String?> addQuiz(Quiz quiz) async {
  try {
    final uid = "${loggedInUser?.uid}${unique.key}";
    final quizzesReference = _database.child('Quizzes/$uid');
    await quizzesReference.set(quiz.toMap());
    return uid;
  } catch (e) {
    return null;
  }
}

Future<bool> removeQuiz(String uid) async {
  try {
    final quizReference = _database.child('Quizzes/$uid');
    await quizReference.remove();
    return true;
  } catch (e) {
    return false;
  }
}

Future<String?> addComment(Comment comment) async {
  try {
    final uid = "${loggedInUser?.uid}${unique.key}";
    final commentsReference = _database.child('Comments/$uid/');
    await commentsReference.set(comment.toMap());
    return uid;
  } catch (e) {
    return null;
  }
}

Future<bool> addCommentToUserAndQuiz(String commentUid, String quizUid) async {
  try {
    final userCommentsReference =
        _database.child("AppUsers/${loggedInUser!.uid}/comments/");

    var data = await userCommentsReference.get();
    List? userCommentsList = jsonDecode(jsonEncode(data.value));
    if (userCommentsList == null) {
      userCommentsList = [commentUid];
    } else {
      userCommentsList.add(commentUid);
    }
    await userCommentsReference.set(userCommentsList);

    // set for quiz comments

    final quizCommentsReference = _database.child("Quizzes/$quizUid/comments/");

    data = await quizCommentsReference.get();
    List? quizCommentsList = jsonDecode(jsonEncode(data.value));
    if (quizCommentsList == null) {
      quizCommentsList = [commentUid];
    } else {
      quizCommentsList.add(commentUid);
    }
    await quizCommentsReference.set(quizCommentsList);

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> removeCommentfromAll(String uid, String quizUid) async {
  try {
    final commentReference = _database.child('Comments/$uid');
    await commentReference.remove();

    final userCommentReference =
        _database.child('AppUsers/${loggedInUser?.uid}/comments/');
    var data = await userCommentReference.get();
    List? userComments = jsonDecode(jsonEncode(data.value));
    if (userComments == null) {
      userComments = [];
    } else {
      userComments.remove(uid);
    }
    await userCommentReference.set(userComments);

    final quizCommentReference = _database.child('Quizzes/$quizUid/comments/');
    data = await quizCommentReference.get();
    List? quizComments = jsonDecode(jsonEncode(data.value));
    if (quizComments == null) {
      quizComments = [];
    } else {
      quizComments.remove(uid);
    }
    quizCommentReference.set(quizComments);

    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<List<Comment>> getQuizComments(String quizUid, List quizComments) async {
  List<Comment> comments = [];
  List otherComments = [];
  for (String userComment in quizComments) {
    if (userComment.contains(loggedInUser!.uid)) {
      final commentReference = _database.child("Comments/$userComment");
      final data = await commentReference.get();
      final Map commentMap = jsonDecode(jsonEncode(data.value));
      commentMap.putIfAbsent("uid", () => userComment);
      comments.add(Comment.fromMap(commentMap));
    } else {
      otherComments.add(userComment);
    }
  }
  for (String commentUid in otherComments) {
    final commentReference = _database.child("Comments/$commentUid");
    final data = await commentReference.get();
    final Map commentMap = jsonDecode(jsonEncode(data.value));
    commentMap.putIfAbsent("uid", () => commentUid);

    comments.add(Comment.fromMap(commentMap));
  }
  return comments;
}

Future<Quiz?> getQuiz(String uid) async {
  try {
    final quizReference = _database.child('Quizzes/$uid');
    final data = await quizReference.get();
    final dataMap = jsonDecode(jsonEncode(data));
    return Quiz.fromMap(dataMap);
  } catch (e) {
    return null;
  }
}

Future<ReducedQuiz?> getReducedQuiz(String uid) async {
  try {
    final quizReference = _database.child('Quizzes/$uid');
    final data = await quizReference.get();
    final dataMap = jsonDecode(jsonEncode(data));
    return ReducedQuiz.fromQuizMap(dataMap);
  } catch (e) {
    return null;
  }
}

Future<Comment?> getComment(String uid) async {
  try {
    final commentReference = _database.child('Comments/$uid');
    final data = await commentReference.get();
    final dataMap = jsonDecode(jsonEncode(data.value));
    return Comment.fromMap(dataMap);
  } catch (e) {
    return null;
  }
}

Future<Question?> getQuestion(String uid) async {
  try {
    final questionReference = _database.child('Questions/$uid');
    final data = await questionReference.get();
    final Map dataMap = jsonDecode(jsonEncode(data.value));
    dataMap.putIfAbsent("uid", () => uid);
    return Question.fromMap(dataMap);
  } catch (e) {
    return null;
  }
}

Future<bool> addQuestionsToQuiz(
    List<String> questionsUids, String quizUid) async {
  try {
    final quizQuestionsReference =
        _database.child("Quizzes/$quizUid/questions");
    // final questionReference = database.child("Questions/$questionUid");

    await quizQuestionsReference.set(questionsUids);

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> addQuizToCurrentUser(Quiz quiz) async {
  try {
    final userQuizzesReference =
        _database.child("AppUsers/${loggedInUser?.uid}/quizzes");
    final userQuizzes = await userQuizzesReference.get();
    final quizzesList = jsonDecode(jsonEncode(userQuizzes.value));

    if (quizzesList == null) {
      await userQuizzesReference.set([quiz.uid]);
    } else {
      quizzesList.add(quiz.uid);
      await userQuizzesReference.set(quizzesList);
    }
    return true;
  } catch (e) {
    return false;
  }
}

Future<List<Quiz>?> getDemoQuizzesList(int amount) async {
  try {
    final quizzesReference = _database.child("Quizzes");
    final data = await quizzesReference.limitToFirst(amount).get();
    var dataMaps = jsonDecode(jsonEncode(data.value));

    List<Quiz> quizList = [];

    for (String key in dataMaps.keys) {
      Map map = dataMaps[key];
      map.putIfAbsent("uid", () => key);
      quizList.add(Quiz.fromMap(map));
    }

    return quizList;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<bool> addQuizToUserLiked(String quizUid) async {
  try {
    final userLikedQuizzesReference =
        _database.child("AppUsers/${loggedInUser!.uid}/quizzesLiked");
    final data = await userLikedQuizzesReference.get();
    List? likedList = jsonDecode(jsonEncode(data.value));
    if (likedList == null) {
      likedList = [quizUid];
    } else {
      likedList.add(quizUid);
    }
    await userLikedQuizzesReference.set(likedList);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> removeQuizFromUserLiked(String quizUid) async {
  try {
    final userLikedQuizzesReference =
        _database.child("AppUsers/${loggedInUser!.uid}/quizzesLiked");
    final data = await userLikedQuizzesReference.get();
    List? likedList = jsonDecode(jsonEncode(data.value));
    if (likedList == null) {
      likedList = [quizUid];
    } else {
      likedList.remove(quizUid);
    }
    await userLikedQuizzesReference.set(likedList);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> addQuizToUserDisliked(String quizUid) async {
  try {
    final userDislikedQuizzesReference =
        _database.child("AppUsers/${loggedInUser!.uid}/quizzesDisliked");
    final data = await userDislikedQuizzesReference.get();
    List? dislikedList = jsonDecode(jsonEncode(data.value));
    if (dislikedList == null) {
      dislikedList = [quizUid];
    } else {
      dislikedList.add(quizUid);
    }
    await userDislikedQuizzesReference.set(dislikedList);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> removeQuizFromUserDisliked(String quizUid) async {
  try {
    final userDislikedQuizzesReference =
        _database.child("AppUsers/${loggedInUser!.uid}/quizzesDisliked");
    final data = await userDislikedQuizzesReference.get();
    List? dislikedList = jsonDecode(jsonEncode(data.value));
    if (dislikedList == null) {
      dislikedList = [quizUid];
    } else {
      dislikedList.remove(quizUid);
    }
    await userDislikedQuizzesReference.set(dislikedList);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> addToQuizLikes(String quizUid) async {
  try {
    final likesReference = _database.child("Quizzes/$quizUid/likes");
    final data = await likesReference.get();
    int? likes = jsonDecode(jsonEncode(data.value));
    if (likes == null) {
      likes = 1;
    } else {
      likes += 1;
    }
    await likesReference.set(likes);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> removeFromQuizLikes(String quizUid) async {
  try {
    final likesReference = _database.child("Quizzes/$quizUid/likes");
    final data = await likesReference.get();
    int? likes = jsonDecode(jsonEncode(data.value));
    if (likes == null) {
      likes = 1;
    } else {
      likes -= 1;
    }
    await likesReference.set(likes);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> addToQuizDislikes(String quizUid) async {
  try {
    final dislikesReference = _database.child("Quizzes/$quizUid/dislikes");
    final data = await dislikesReference.get();
    int? dislikes = jsonDecode(jsonEncode(data.value));
    if (dislikes == null) {
      dislikes = 1;
    } else {
      dislikes += 1;
    }
    await dislikesReference.set(dislikes);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> removeFromQuizDislikes(String quizUid) async {
  try {
    final dislikesReference = _database.child("Quizzes/$quizUid/dislikes");
    final data = await dislikesReference.get();
    int? dislikes = jsonDecode(jsonEncode(data.value));
    if (dislikes == null) {
      dislikes = 1;
    } else {
      dislikes -= 1;
    }
    await dislikesReference.set(dislikes);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> followAccount(String uid) async {
  try {
    final userFollowedReference =
        _database.child("AppUsers/${loggedInUser!.uid}/accountsFollowed");
    var data = await userFollowedReference.get();
    List? followedList = jsonDecode(jsonEncode(data.value));
    if (followedList == null) {
      followedList = [uid];
    } else {
      followedList.add(uid);
    }
    await userFollowedReference.set(followedList);

    final followedUserReference = _database.child("AppUsers/$uid/followers");
    data = await followedUserReference.get();
    List? followerList = jsonDecode(jsonEncode(data.value));
    if (followerList == null) {
      followerList = [loggedInUser!.uid];
    } else {
      followerList.add(loggedInUser!.uid);
    }
    await followedUserReference.set(followerList);

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> unfollowAccount(String uid) async {
  try {
    final userFollowedReference =
        _database.child("AppUsers/${loggedInUser!.uid}/accountsFollowed");
    var data = await userFollowedReference.get();
    List? followedList = jsonDecode(jsonEncode(data.value));

    if (followedList == null) {
      return true;
    } else {
      followedList.remove(uid);
    }
    await userFollowedReference.set(followedList);

    final followedUserReference = _database.child("AppUsers/$uid/followers");
    data = await followedUserReference.get();
    List? followerList = jsonDecode(jsonEncode(data.value));
    if (followerList == null) {
      followerList = [];
    } else {
      followerList.remove(loggedInUser!.uid);
    }
    await followedUserReference.set(followerList);

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> addQuestionLikeToAll(String uid) async {
  try {
    final questionLikesReference = _database.child("Questions/$uid/likes");
    var data = await questionLikesReference.get();
    int? likes = jsonDecode(jsonEncode(data.value));
    if (likes == null) {
      likes = 1;
    } else {
      likes++;
    }
    await questionLikesReference.set(likes);

    final userQuestionLikedReference =
        _database.child("AppUsers/${loggedInUser!.uid}/questionsLiked");
    data = await userQuestionLikedReference.get();
    List? questions = jsonDecode(jsonEncode(data.value));
    if (questions == null) {
      questions = [uid];
    } else {
      questions.add(uid);
    }
    await userQuestionLikedReference.set(questions);

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> removeQuestionLikeFromAll(String uid) async {
  try {
    final questionLikesReference = _database.child("Questions/$uid/likes");
    var data = await questionLikesReference.get();
    int? likes = jsonDecode(jsonEncode(data.value));
    if (likes == null) {
      likes = 0;
    } else {
      likes -= 1;
    }
    await questionLikesReference.set(likes);

    final userQuestionLikedReference =
        _database.child("AppUsers/${loggedInUser!.uid}/questionsLiked");
    data = await userQuestionLikedReference.get();
    List? questions = jsonDecode(jsonEncode(data.value));
    if (questions == null) {
      questions = [];
    } else {
      questions.remove(uid);
    }
    await userQuestionLikedReference.set(questions);

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> addQuestionDisLikeToAll(String uid) async {
  try {
    final questionDislikesReference =
        _database.child("Questions/$uid/dislikes");
    var data = await questionDislikesReference.get();
    int? dislikes = jsonDecode(jsonEncode(data.value));
    if (dislikes == null) {
      dislikes = 1;
    } else {
      dislikes++;
    }
    await questionDislikesReference.set(dislikes);

    final userQuestionDislikedReference =
        _database.child("AppUsers/${loggedInUser!.uid}/questionsDisliked");
    data = await userQuestionDislikedReference.get();
    List? questions = jsonDecode(jsonEncode(data.value));
    if (questions == null) {
      questions = [uid];
    } else {
      questions.add(uid);
    }
    await userQuestionDislikedReference.set(questions);

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> removeQuestionDislikeFromAll(String uid) async {
  try {
    final questionDislikesReference =
        _database.child("Questions/$uid/dislikes");
    var data = await questionDislikesReference.get();
    int? dislikes = jsonDecode(jsonEncode(data.value));
    if (dislikes == null) {
      dislikes = 0;
    } else {
      dislikes -= 1;
    }
    await questionDislikesReference.set(dislikes);

    final userQuestionDislikedReference =
        _database.child("AppUsers/${loggedInUser!.uid}/questionsDisliked");
    data = await userQuestionDislikedReference.get();
    List? questions = jsonDecode(jsonEncode(data.value));
    if (questions == null) {
      questions = [];
    } else {
      questions.remove(uid);
    }
    await userQuestionDislikedReference.set(questions);

    return true;
  } catch (e) {
    return false;
  }
}

Future<List<Quiz>?> getLikedQuizzes(QuizAppUser user) async {
  try {
    List<Quiz> quizList = [];
    final reference = _database.child("Quizzes");
    var quizUids = user.quizzesLiked;
    for (var quizUid in quizUids!) {
      final data = await reference.child(quizUid).get();
      Map quizMap = jsonDecode(jsonEncode(data.value));
      quizMap.putIfAbsent("uid", () => quizUid);

      quizList.add(Quiz.fromMap(quizMap));
    }
    return quizList;
  } catch (e) {
    return null;
  }
}

Future<List<Quiz>?> getOwnQuizzes(QuizAppUser user) async {
  try {
    List<Quiz> quizList = [];
    final reference = _database.child("Quizzes");
    var quizUids = user.quizzes;
    for (var quizUid in quizUids!) {
      final data = await reference.child(quizUid).get();
      Map quizMap = jsonDecode(jsonEncode(data.value));
      quizMap.putIfAbsent("uid", () => quizUid);
      quizList.add(Quiz.fromMap(quizMap));
    }
    return quizList;
  } catch (e) {
    return null;
  }
}

// Future<List<Quiz>?> getDemoQuizzesList(int amount) async {
//   try {
//     final quizzesReference = _database.child("Quizzes");
//     final data = await quizzesReference.limitToFirst(amount).get();
//     var dataMaps = jsonDecode(jsonEncode(data.value));

//     List<Quiz> quizList = [];

//     for (String key in dataMaps.keys) {
//       Map map = dataMaps[key];
//       map.putIfAbsent("uid", () => key);
//       quizList.add(Quiz.fromMap(map));
//     }

//     return quizList;
//   } catch (e) {
//     print(e);
//     return null;
//   }
// }

Future<QuizAppUser?> get currentUser async {
  final userData = await fetchCurrentUserData();
  if (userData == null) {
    return null;
  }
  return QuizAppUser.fromMap(userData);
}

Future<List<Quiz>> getFollowingQuizzes() async {
  var user = await currentUser;
  List<Quiz> quizzes = [];
  List quizzesUids = [];

  for (var accountUid in user!.accountsFollowed!) {
    final followedUserQuizzesData =
        await _database.child("AppUsers/$accountUid/quizzes").get();
    var uids = jsonDecode(jsonEncode(followedUserQuizzesData.value));
    if (uids == null) {
      uids = [];
    } else {
      quizzesUids.addAll(uids);
    }
  }

  for (var uid in quizzesUids) {
    final quizData = await _database.child("Quizzes/$uid").get();
    Map quizMap = jsonDecode(jsonEncode(quizData.value));
    quizMap.putIfAbsent("uid", () => quizData.key);
    quizzes.add(Quiz.fromMap(quizMap));
  }
  return quizzes;
}

Future<List<Quiz>> getTopLikedQuizzes() async {
  var user = await currentUser;
  List<Quiz> quizzes = [];

  final sortedQuizzesReference = _database.child("Quizzes");
  final data =
      await sortedQuizzesReference.orderByChild("likes").limitToFirst(3).once();
  Map dataMaps = jsonDecode(jsonEncode(data.snapshot.value));

  for (var dataMapKey in dataMaps.keys) {
    Map quizMap = dataMaps[dataMapKey];
    quizMap.putIfAbsent("uid", () => dataMapKey);

    quizzes.add(Quiz.fromMap(quizMap));
  }
  return quizzes;
}

Future getFollowersNames() async {
  var names = [];
  var user = await currentUser;
  for (var accountUid in user!.followers!) {
    var data = await _database.child("AppUsers/$accountUid/displayName").get();
    names.add(jsonDecode(jsonEncode(data.value)));
  }
  return names;
}

Future getAccountFollowedNames() async {
  var names = [];
  var user = await currentUser;
  for (var accountUid in user!.accountsFollowed!) {
    var data = await _database.child("AppUsers/$accountUid/displayName").get();
    names.add(jsonDecode(jsonEncode(data.value)));
  }
  return names;
}
