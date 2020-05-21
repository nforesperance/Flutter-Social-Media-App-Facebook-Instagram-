import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/pages/PostScreenPage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: "Notifications"),
      body: Container(
        child: FutureBuilder(
          future: retrieveNotifications(),
          builder: (context, dataSnapshot) {
            if (!dataSnapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              children: dataSnapshot.data,
            );
          },
        ),
      ),
    );
  }

  retrieveNotifications() async {
    QuerySnapshot querySnapshot = await activityFeedReference
        .document(currentSignInUser.id)
        .collection("feedItems")
        .orderBy("timstamp", descending: true)
        .limit(50)
        .getDocuments();
    List<NotificationsItem> notficationItems = [];
    querySnapshot.documents.forEach((document) {
      notficationItems.add(NotificationsItem.fromDocument(document));
    });
    return notficationItems;
  }
}

String notificationItemText;
Widget mediaPreview;

class NotificationsItem extends StatelessWidget {
  final String username;
  final String type;
  final String commentData;
  final String userId;
  final String userProfileImage;
  final String postID;
  final String url;
  final Timestamp timestamp;

  const NotificationsItem(
      {this.username,
      this.type,
      this.commentData,
      this.userId,
      this.userProfileImage,
      this.postID,
      this.url,
      this.timestamp});
  factory NotificationsItem.fromDocument(DocumentSnapshot document) {
    return NotificationsItem(
      username: document["username"],
      type: document["type"],
      commentData: document["commentData"],
      userId: document["userId"],
      userProfileImage: document["userProfileImage"],
      postID: document["postID"],
      url: document["url"],
      timestamp: document["timestamp"],
    );
  }
  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: ListTile(
        title: GestureDetector(
          onTap: () => displayUserProfile(context, profileId: userId),
          child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: " $notificationItemText",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ])),
        ),
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(userProfileImage),
        ),
        subtitle: Text(
          timeAgo.format(timestamp.toDate()),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: mediaPreview,
      ),
    );
  }

  displayUserProfile(BuildContext context, {String profileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  profileId: profileId,
                )));
  }

  void configureMediaPreview(BuildContext context) {
    if (type == "comment" || type == "like") {
      mediaPreview = GestureDetector(
        onTap: () => displayFullPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(url))),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }
    if (type == "like") {
      notificationItemText = "liked your post";
    } else if (type == "comment") {
      notificationItemText = "replied $commentData";
    } else if (type == "follow") {
      notificationItemText = "started following you";
    } else {
      notificationItemText = "Error: Unknown type = $type";
    }
  }

  displayFullPost(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreenPage(
                  postID: postID,
                  userId: userId,
                )));
  }
}
