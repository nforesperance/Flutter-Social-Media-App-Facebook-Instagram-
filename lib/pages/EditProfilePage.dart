import 'package:buddiesgram/auth/utils/firebase_auth.dart';
import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;

  const EditProfilePage({Key key, this.currentOnlineUserId}) : super(key: key);
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _profileName = TextEditingController();
  TextEditingController _bio = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool _bioValid = false;
  bool _profileNameValid = false;
  User user;
  
  void initState(){
    super.initState();
    getAndDisplayUserInfo();
  }
  getAndDisplayUserInfo(){
    _profileName.text=currentSignInUser.profileName;
    _bio.text = currentSignInUser.bio;
    setState(() {
     _bioValid = true;
  _profileNameValid = true;
    });
  }

  updateUserProfile() async {
    setState(() {
      _profileName.text.trim().length < 3 || _profileName.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;
          _bio.text.trim().length > 200
          ? _bioValid = false
          : _bioValid = true;
    });
    if(_bioValid & _profileNameValid){
      setState(() {
        loading=true;
      });
     await  usersReference.document(currentSignInUser.id)
      .updateData({
        "profileName":_profileName.text,
        "bio":_bio.text
      });
      DocumentSnapshot documentSnapshot =
          await usersReference.document(currentSignInUser.id).get();
      currentSignInUser = User.fromDocument(documentSnapshot);
      setState(() {
        loading=false;
      });

      SnackBar snackBar = SnackBar(content: Text("Profile Updated Successfully"));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    UserRepository userRepository = Provider.of<UserRepository>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: loading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 7.0),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundImage: CachedNetworkImageProvider(currentSignInUser.url),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            createProfileNameTextFormField(),
                            createBioTextFormField(),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 29.0, left: 50.0, right: 50.0),
                              child: RaisedButton(
                                color: Colors.white,
                                child: Text(
                                  "             Update            ",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                ),
                                onPressed: updateUserProfile,
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                  top: 10.0, left: 50.0, right: 50.0),
                              child: RaisedButton(
                                color: Colors.red,
                                child: Text(
                                  "Log Out",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                                onPressed: (){
                                  Navigator.pop(context,
                                    userRepository.signOut());
                                },
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Column createProfileNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Profile Name",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextFormField(
          style: TextStyle(
            color: Colors.white,
          ),
          controller: _profileName,
          decoration: InputDecoration(
              hintText: "Enter new Profile Name here...",
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorText: _profileNameValid ? null : "Prolfile Name too short"),
        ),
      ],
    );
  }

  Column createBioTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextFormField(
          style: TextStyle(
            color: Colors.white,
          ),
          controller: _bio,
          decoration: InputDecoration(
              hintText: "Enter bio here ...",
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorText: _bioValid ? null : "Bio either empty or too long"),
        ),
      ],
    );
  }
}
