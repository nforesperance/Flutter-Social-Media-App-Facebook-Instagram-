import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class PostScreenPage extends StatelessWidget {
  final String postID;
  final String userId; // better as owner id

  const PostScreenPage({Key key, this.postID, this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postsReference
            .document(userId)
            .collection("userPosts")
            .document(postID)
            .get(),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.hasError) {
            print(dataSnapshot.error);
          }
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }

          Post post = Post.fromDocument(dataSnapshot.data);
          return Center(
            child: Scaffold(
              appBar: header(context, title: post.description),
              body: ListView(
                children: <Widget>[
                  Container(
                    child: post,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
