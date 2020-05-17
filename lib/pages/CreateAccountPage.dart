import 'dart:async';

import 'package:buddiesgram/auth/utils/firebase_auth.dart';
import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _username = TextEditingController();
  @override
  Widget build(BuildContext parentContext) {
    final user = Provider.of<UserRepository>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, title: "Settings", disableBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 26.0),
                  child: Text(
                    "Set Up a Username",
                    style: TextStyle(fontSize: 26.0,color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Container(
                    child: Form(
                        key: _formKey,
                        autovalidate: true,
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          validator: (val) {
                            if (val.trim().length < 5 || val.isEmpty) {
                              return "Username is too Short";
                            } else if (val.trim().length > 15) {
                              return "Username is too Long";
                            } else
                              return null;
                          },
                          controller: _username,
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              border: OutlineInputBorder(),
                              labelText: "Username",
                              labelStyle: TextStyle(fontSize: 20.0,color: Colors.white),
                              hintText: "must be at least 5 characters",
                              hintStyle: TextStyle(color: Colors.grey)),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                  child: Material(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.green,
                      elevation: 0.0,
                      child: MaterialButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                           await Firestore.instance
                                .collection("users")
                                .document(user.currentUser.uid)
                                .setData({
                              "id": user.currentUser.uid,
                              "username": _username.text,
                              "profileName": user.currentUser.displayName,
                              "email": user.currentUser.email,
                              "url": user.currentUser.photoUrl,
                              "bio": "",
                              "timestamp": timestamp
                            });
                             DocumentSnapshot documentSnapshot = await usersReference.document(user.currentUser.uid)
                            .get();
                            currentSignInUser = User.fromDocument(documentSnapshot);
                            user.homePage();
                          }
                        },
                        minWidth: MediaQuery.of(context).size.width,
                        child: Text(
                          "Proceed",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18.0),
                        ),
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
