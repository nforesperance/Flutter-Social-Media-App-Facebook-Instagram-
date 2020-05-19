import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  TextEditingController _search = TextEditingController();
  Future<QuerySnapshot> searchResults;

  clearSearch() {
    _search.clear();
  }

  controlSearch(String txt) {
    Future<QuerySnapshot> allUsers = usersReference
        .where("profileName", isGreaterThanOrEqualTo: txt)
        .getDocuments();
    setState(() {
      searchResults = allUsers;
    });
  }

  AppBar searchPageHeader() {
    return AppBar(
      backgroundColor: Colors.black,
      title: TextFormField(
        style: TextStyle(fontSize: 18.0, color: Colors.white),
        controller: _search,
        decoration: InputDecoration(
          hintText: "Search here ....",
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          prefixIcon: Icon(
            Icons.person_pin,
            color: Colors.white,
            size: 30,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.white),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: controlSearch,
      ),
    );
  }

  Container displayNoSearchResult() {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(
              Icons.group,
              color: Colors.grey,
              size: 200.0,
            ),
            Text(
              "Search Results",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 65.0),
            )
          ],
        ),
      ),
    );
  }

  displaySearchResult() {
    return FutureBuilder(
      future: searchResults,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchUsersResult = [];
        dataSnapshot.data.documents.forEach((document) {
          User user = User.fromDocument(document);
          UserResult userResult = UserResult(user: user);
          searchUsersResult.add(userResult);
        });
        return ListView(children: searchUsersResult);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: searchPageHeader(),
      body: searchResults == null
          ? displayNoSearchResult()
          : displaySearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  const UserResult({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(3.0),
        child: Container(
          color: Colors.white54,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () => displayUserProfile(context, profileId: user.id),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                  title: Text(user.profileName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      )),
                  subtitle: Text(user.username,
                      style: TextStyle(color: Colors.black, fontSize: 13.0)),
                ),
              )
            ], 
          ),
        ));
  }

  displayUserProfile(BuildContext context, {String profileId}) {
    Navigator.push(context, 
    MaterialPageRoute(builder: (context)=>ProfilePage(profileId: profileId,))
    );
  }
}
