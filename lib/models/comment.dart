class Comment {
  final String? uid;
  final String body;
  final String postedBy;

  Comment({this.uid, required this.body, required this.postedBy});

  factory Comment.fromMap(Map map) {
    Map nullMap = {
      "uid": null,
    };
    Map finalMap = {};
    finalMap.addAll(map);

    nullMap.forEach((key, value) {
      finalMap.putIfAbsent(key, () => value);
    });

    return Comment(
      uid: finalMap["uid"],
      body: finalMap["body"],
      postedBy: finalMap["postedBy"],
    );
  }

  Map toMap() {
    return {
      "uid": uid,
      "body": body,
      "postedBy": postedBy,
    };
  }
}
