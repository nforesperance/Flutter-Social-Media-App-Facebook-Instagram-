import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/widgets/CImageWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:buddiesgram/pages/HomePage.dart';

class Post extends StatefulWidget {
  final String postID;
  final String ownerId;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;

  const Post(
      {Key key,
      this.postID,
      this.ownerId,
      this.likes,
      this.username,
      this.description,
      this.location,
      this.url})
      : super(key: key);
  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postID: documentSnapshot['postID'],
      ownerId: documentSnapshot['ownerId'],
      likes: documentSnapshot['likes'],
      username: documentSnapshot['username'],
      description: documentSnapshot['description'],
      location: documentSnapshot['location'],
      url: documentSnapshot['url'],
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }
    int counter = 0;
    likes.values.forEach((eachValue) {
      if (eachValue == true) {
        counter = counter + 1;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
      postID: this.postID,
      ownerId: this.ownerId,
      likes: this.likes,
      username: this.username,
      description: this.description,
      location: this.location,
      url: this.url,
      likesCount: this.getTotalNumberOfLikes(this.likes));
}

class _PostState extends State<Post> {
  final String postID;
  final String ownerId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  final int likesCount;

  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentSignInUser.id;

  _PostState({
    this.postID,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likesCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(),
          creatPostPicture(),
          creatPostFooter(),
        ],
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
        future: usersReference.document(currentOnlineUserId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(dataSnapshot.data);
          bool isPostOwner = currentOnlineUserId == ownerId;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.url),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              child: Text(
                user.username,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onDoubleTap: () => print("Show Profile"),
            ),
            subtitle: Text(
              location,
              style: TextStyle(color: Colors.white),
            ),
            trailing: isPostOwner
                ? IconButton(
                    icon: Icon(
                      Icons.more,
                      color: Colors.white,
                    ),
                    onPressed: () => print("Deleted"))
                : null,
          );
        });
  }

  creatPostPicture() {
    return GestureDetector(
      onDoubleTap: () => print("Like Post"),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
         Image.network(url),
        ],
      ),
    );
  }

  creatPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () => print("Like Post"),
              child: Icon(Icons.favorite,color: Colors.pink,
                // isLiked ? Icons.favorite : Icons.favorite_border,
                // size: 28.0,
                // color: Colors.pink,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () => print("Show Comments"),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 28.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likesCount likes",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username ",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                "$description",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
