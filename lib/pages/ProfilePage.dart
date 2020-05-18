import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/EditProfilePage.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String profileId;

  const ProfilePage({Key key, this.profileId}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentSignInUser.id;
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
                              createColumns("Posts", 0),
                              createColumns("Followers", 0),
                              createColumns("Following", 0),
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
                padding: EdgeInsets.only(top:13.0),
                child: Text("@ "+user.username,
                style:TextStyle(
                 fontSize: 18.0,
                 color: Colors.white,

                ),
                ),
                ),
                Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top:4.0),
                child: Text(user.profileName,
                style:TextStyle(
                 fontSize: 14.0,
                 color: Colors.white,
                 
                ),
                ),
                ),
                Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top:3.0),
                child: Text(user.bio,
                style:TextStyle(
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
    }
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
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:Colors.black,
            border: Border.all(color:Colors.grey),
            borderRadius: BorderRadius.circular(6.0)
          ),
        ),
      ),
    );
  }

  editUserProfle (){
  Navigator.push(context,MaterialPageRoute(builder: (context)=>EditProfilePage(currentOnlineUserId:currentOnlineUserId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: "Profile"),
      body: ListView(
        children: <Widget>[
          creatProfileTopView(),
        ],
      ),
    );
  }
}
