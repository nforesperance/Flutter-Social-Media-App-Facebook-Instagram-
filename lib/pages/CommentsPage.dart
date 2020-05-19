import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:timeago/timeago.dart' as tAgo;

class CommentsPage extends StatefulWidget {
  final String postID;
  final String postOwnerId;
  final String postImageUrl;

  const CommentsPage(
      {Key key, this.postID, this.postOwnerId, this.postImageUrl})
      : super(key: key);
  @override
  CommentsPageState createState() => CommentsPageState(
      postID: this.postID,
      postOwnerId: this.postOwnerId,
      postImageUrl: this.postImageUrl);
}

class CommentsPageState extends State<CommentsPage> {
  final String postID;
  final String postOwnerId;
  final String postImageUrl;

  TextEditingController _commentController = TextEditingController();

  CommentsPageState({this.postID, this.postOwnerId, this.postImageUrl});

  retrieveComents() {
    return StreamBuilder(
        stream: commentsReference
            .document(postID)
            .collection("comments")
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          List<Comment> comments = [];
          dataSnapshot.data.documents.forEach((document) {
            comments.add(Comment.fromDocument(document));
          });
          return ListView(
            children: comments,
          );
        });
  }

  saveComment() {
    commentsReference.document(postID).collection("comments").add({
      "username": currentSignInUser.username,
      "userId": currentSignInUser.id,
      "url": currentSignInUser.url,
      "comment": _commentController.text,
      "timestamp": DateTime.now(),
    });

    bool isNotPostOwner = postOwnerId != currentSignInUser.id;
    if (isNotPostOwner) {
      //Make sure to test this and very consoe
      activityFeedReference.document(postOwnerId).collection("feedItems").add({
        "type": "comment",
        "commentDate": timestamp,
        "userId": currentSignInUser.id,
        "urlProfileImage": currentSignInUser.url,
        "username": currentSignInUser.username,
        "postID": postID,
        "url": postImageUrl
      });
    }
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(
            child: retrieveComents(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                  labelText: "Leave a comment ...",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  )),
              style: TextStyle(color: Colors.white),
            ),
            trailing: OutlineButton(
              onPressed: () => saveComment(),
              borderSide: BorderSide.none,
              child: Text("Add",
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;

  const Comment(
      {Key key,
      this.username,
      this.userId,
      this.url,
      this.comment,
      this.timestamp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                username + ":  " + comment,
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              subtitle: Text(tAgo.format(timestamp.toDate()),
              style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  factory Comment.fromDocument(DocumentSnapshot document) {
    return Comment(
      username: document["username"],
      userId: document["userId"],
      url: document["url"],
      comment: document["comment"],
      timestamp: document["timestamp"],
    );
  }
}
