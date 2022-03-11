import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentDisplay extends StatelessWidget {
  final Comment comment;
  final String userUid;
  final Function onDeletePressed;
  const CommentDisplay(this.comment, this.userUid, this.onDeletePressed,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width * 0.7,
      child: Card(
        elevation: 3,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    comment.postedBy,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(comment.body),
                )),
              ],
            ),
          ),
          comment.uid!.contains(userUid)
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () {
                      onDeletePressed(comment);
                    },
                  ),
                )
              : Container(),
        ]),
      ),
    );
  }
}
