import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/CreateAccountPage.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated,
  Authenticating_Google,
  SigningUP,
  SignUp,
  Set_Username,
}

class UserRepository with ChangeNotifier {
  final FirebaseAuth auth;
  FirebaseUser _user;
  Status _status = Status.Uninitialized;
  String email = "";
  String name = "";
  String photoUrl = "";
  FirebaseUser currentUser;

  //update
  SharedPreferences preferences;

  UserRepository.instance({this.auth}) {
    auth.onAuthStateChanged.listen(onAuthStateChanged);
  }

  Status get status => _status;
  FirebaseUser get user => _user;

  Future<bool> signIn(String email, String password) async {
    this.email = email;
    this.name = name;
    try {
      _status = Status.Authenticating;
      notifyListeners();
      FirebaseUser user = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      DocumentSnapshot documentSnapshot =
          await usersReference.document(user.uid).get();
      currentSignInUser = User.fromDocument(documentSnapshot);
      _status = Status.Authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    auth.signOut();
    this.email = "";
    this.name = "";
    this.photoUrl = "";
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future<void> onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  Future handleSignIn(context) async {
    preferences = await SharedPreferences.getInstance();
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount account = await googleSignIn.signIn();
      if (account == null) return false;
      _status = Status.Authenticating_Google;
      notifyListeners();
      this.email = account.email;
      this.name = account.displayName;
      this.photoUrl = account.photoUrl;
      print(account.photoUrl);
      FirebaseUser user =
          await auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: (await account.authentication).idToken,
        accessToken: (await account.authentication).accessToken,
      ));
      if (user == null) {
        Fluttertoast.showToast(msg: "Login Failed");
      } else {
        final QuerySnapshot result = await Firestore.instance
            .collection("users")
            .where("id", isEqualTo: user.uid)
            .getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        currentUser = user;
        DocumentSnapshot documentSnapshot =
            await usersReference.document(user.uid).get();
        currentSignInUser = User.fromDocument(documentSnapshot);
        // if the user is not already stored in our own created users collection
        if (documents.length == 0) {
          _status = Status.Set_Username;
          notifyListeners();
          return true;
        }

        // if user is not in our collection
        else {
          await preferences.setString("id", documents[0]["id"]);
          await preferences.setString("username", documents[0]["username"]);
          await preferences.setString("photoUrl", documents[0]["photoUrl"]);
        }
        Fluttertoast.showToast(msg: "Login was successful");

        _status = Status.Authenticated;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e.message);
      print("Error logging with google");
      return false;
    }
  }

  Future signUpPage() async {
    _status = Status.SignUp;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future signInPage() async {
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future homePage() async {
    _status = Status.Authenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future register(
      String username, String email, String password, String gender) async {
    _status = Status.SigningUP;
    notifyListeners();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((user) {
        Firestore.instance.collection("users").document(user.uid).setData({
          "id": user.uid,
          "username": username,
          "photoUrl": user.photoUrl,
          "gender": gender,
          "email": user.email
        }).then((onValue) {
          _status = Status.Unauthenticated;
          notifyListeners();
          return Future.delayed(Duration.zero);
          print(
              "*************SUCESS SUCESS SUCESS SUCESS SUCESS SUCESS*************");
        }).catchError((onError) {
          print(
              "*****************FAILDED FAILDED FAILDED FAILDED FAILDED FAILDED ***********");
        });
      }).catchError((err) {
        print(err.toString());
      });
    } else {
      auth.signOut();
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((user) {
        Firestore.instance.collection("users").document(user.uid).setData({
          "id": user..uid,
          "username": username,
          "photoUrl": user..photoUrl,
          "gender": gender,
          "email": user.email
        }).then((onValue) {
          _status = Status.Unauthenticated;
          notifyListeners();
          return Future.delayed(Duration.zero);
          print(
              "*************SUCESS SUCESS SUCESS SUCESS SUCESS SUCESS*************");
        }).catchError((onError) {
          print(
              "*****************FAILDED FAILDED FAILDED FAILDED FAILDED FAILDED ***********");
        });
      }).catchError((err) {
        print(err.toString());
      });
    }
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }
  
}
