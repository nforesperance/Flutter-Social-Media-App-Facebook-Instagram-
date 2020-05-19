import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/EditProfilePage.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/PostTileWidget.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String profileId;

  const ProfilePage({Key key, this.profileId}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentSignInUser.id;
  bool loading = false;
  int postsCount = 0;
  List<Post> postList = [];

  String postOrientation = "grid";
  int followersCount = 0;
  int followingsCount = 0;
  bool following = false;

  initState() {
    super.initState();
    getAllProfilePosts();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }

  getAllFollowers() async {
   QuerySnapshot querySnapshot = await followersReference
        .document(widget.profileId)
        .collection("userFollowers")
        .getDocuments();
        setState(() {
          followersCount = querySnapshot.documents.length;
        });
  }

  getAllFollowings() async{
        QuerySnapshot querySnapshot = await followingsReference
        .document(widget.profileId)
        .collection("userFollowings")
        .getDocuments();
        setState(() {
          followingsCount = querySnapshot.documents.length;
        });
  }
  checkIfAlreadyFollowing() async {
    DocumentSnapshot documentSnapshot = await followersReference
        .document(widget.profileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get();
    setState(() {
      following = documentSnapshot.exists;
    });
  }

  creatProfileTopView() {
    return FutureBuilder(
        future: usersReference.document(widget.profileId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(dataSnapshot.data);
          return Padding(
            padding: EdgeInsets.all(17.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(user.url),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              createColumns("Posts", postsCount),
                              createColumns("Followers", followersCount),
                              createColumns("Following", followingsCount),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              createButton(),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 13.0),
                  child: Text(
                    "@ " + user.username,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    user.profileName,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 3.0),
                  child: Text(
                    user.bio,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
                fontWeight: FontWeight.w300),
          ),
        ),
      ],
    );
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.profileId;
    // Case when user is viewing his own profile
    if (ownProfile) {
      return createButtonTitleAndFunction(
          title: "Edit Profile", performFunction: editUserProfle);
    } else if (following) {
      return createButtonTitleAndFunction(
          title: "Unfollow", performFunction: controlUnfollowUser);
    } else if (!following) {
      return createButtonTitleAndFunction(
          title: "Follow", performFunction: controlFollowUser);
    }
  }

  controlUnfollowUser() {
    setState(() {
      following = false;
    });

    followersReference
        .document(widget.profileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    followingsReference
        .document(currentOnlineUserId)
        .collection("userFollowings")
        .document(widget.profileId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
    activityFeedReference
        .document(widget.profileId)
        .collection("feedItems")
        .document(currentOnlineUserId)
        .get()
        .then((documents) {
      if (documents.exists) {
        documents.reference.delete();
      }
    });
  }

  controlFollowUser() {
    setState(() {
      following = true;
    });

    followersReference
        .document(widget.profileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .setData({});
    followingsReference
        .document(currentOnlineUserId)
        .collection("userFollowings")
        .document(widget.profileId)
        .setData({});
    activityFeedReference
        .document(widget.profileId)
        .collection("feedItems")
        .document(currentOnlineUserId)
        .setData({
      "type": "follow",
      "username": currentSignInUser.username,
      "owerId": widget.profileId,
      "timestamp": DateTime.now(),
      "userProfileImage": currentSignInUser.url,
      "userId": currentSignInUser.id,
    });
  }

  createButtonTitleAndFunction({String title, Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 230.0,
          height: 26.0,
          child: Text(
            title,
            style: TextStyle(color: following? Colors.grey:Colors.white70, fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: following? Colors.black:Colors.blueGrey,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6.0)),
        ),
      ),
    );
  }

  editUserProfle() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: "Profile"),
      body: ListView(
        children: <Widget>[
          creatProfileTopView(),
          Divider(),
          createListAndGridPostOrientation(),
          Divider(
            height: 0.0,
          ),
          displayProfilePosts()
        ],
      ),
    );
  }

  displayProfilePosts() {
    if (loading) {
      return circularProgress();
    } else if (postList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Icon(
                Icons.photo_library,
                color: Colors.grey,
                size: 200.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else if (postOrientation == "grid") {
      List<GridTile> gridTileList = [];
      postList.forEach((post) {
        gridTileList.add(GridTile(
          child: PostTile(
            post: post,
          ),
        ));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTileList,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: postList,
      );
    }
  }

  getAllProfilePosts() async {
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await postsReference
        .document(widget.profileId)
        .collection("userPosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    setState(() {
      loading = false;
      postsCount = querySnapshot.documents.length;
      postList =
          querySnapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  createListAndGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.grid_on,
            color: postOrientation == "grid"
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () => setOrientation("grid"),
        ),
        IconButton(
          icon: Icon(
            Icons.list,
            color: postOrientation == "list"
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () => setOrientation("list"),
        )
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
}
