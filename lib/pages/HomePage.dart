import 'package:buddiesgram/pages/NotificationsPage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:buddiesgram/pages/SearchPage.dart';
import 'package:buddiesgram/pages/TimeLinePage.dart';
import 'package:buddiesgram/pages/UploadPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex  = 0;


  // Checks if user is already signed in
  void initState(){
    super.initState();
    
    pageController = PageController();
  }

  loginUser() {
    setState(() {
      isSignedIn = true;
    });
  }

  logoutuser() {
    setState(() {
      isSignedIn = false;
    });
  }

  void dispose(){
    pageController.dispose();
    super.dispose();
  }
  whenPageChanges(int pageIndex){
    setState(() {
      getPageIndex = pageIndex;
    });
  }

  changePage(int pageIndex){
  pageController.animateToPage(pageIndex, duration: Duration(microseconds: 400), 
  curve: Curves.bounceInOut);
  }
  Scaffold buildHomeScreen() {
      return Scaffold(
      body: PageView(
        children: <Widget>[
          TimeLinePage(),
          SearchPage(),
          UploadPage(),
          NotificationsPage(),
          ProfilePage()
        ],
        controller: pageController,
        // This onPageChanged passes the index as parameter
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        // This onTap passes the currentIndex as parameter
        onTap: changePage,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.white,
        inactiveColor: Colors.blueGrey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size:37,)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
        ),
    );
  
  }

  Scaffold buildSignInScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Theme.of(context).accentColor,
            Theme.of(context).primaryColor
          ],
        )),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "EspriGram",
              style: TextStyle(
                fontSize: 92.0,
                color: Colors.white,
                fontFamily: "Signatra",
              ),
            ),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                width: 270.0,
                height: 65.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            "assets/images/google_signin_button.png"),
                        fit: BoxFit.cover)),
              ),
            ),
         
          ],
        ),
      ),
    );
  
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignInScreen();
    }
  }
}
