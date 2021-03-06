import 'dart:io';

import 'package:buddiesgram/auth/utils/firebase_auth.dart';
import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as IMD;

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
with AutomaticKeepAliveClientMixin<UploadPage>  {
  File file;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController _description = TextEditingController();
  TextEditingController _location = TextEditingController();

  captureImageWithCamera(mycontext) async {
    Navigator.pop(mycontext);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 600,
      maxWidth: 970,
    );
    setState(() {
      this.file = imageFile;
    });
  }

  pickImageFromGallery(mycontext) async {
    Navigator.pop(mycontext);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = imageFile;
    });
  }

  takeImage(mycontext) {
    return showDialog(
      context: mycontext,
      builder: (context) {
        return SimpleDialog(
          title: Text("New Post",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                "Capture Image with Image",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                captureImageWithCamera(context);
              },
            ),
            SimpleDialogOption(
              child: Text(
                "Choose Image From Gallery",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                pickImageFromGallery(context);
              },
            ),
            SimpleDialogOption(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  displayUploadScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.add_photo_alternate,
            color: Colors.grey,
            size: 200.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              onPressed: () => takeImage(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0),
              ),
              child: Text(
                "Upload Image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  clearPostInfo() {
    _description.clear();
    _location.clear();
    setState(() {
      file = null;
    });
  }

  getUserCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark myplacemark = placemarks[0];
    // String completAdressInfo =
    //     '${myplacemark.subThoroughfare} ${myplacemark.thoroughfare}, ${myplacemark.subLocality} ${myplacemark.locality}, ${myplacemark.subAdministrativeArea} ${myplacemark.administrativeArea}, ${myplacemark.postalCode} ${myplacemark.country}';

    String specificAdrress = '${myplacemark.locality},${myplacemark.country}';
    _location.text = specificAdrress;
  }

  compressPhoto() async {
    final tempDirectory = await getTemporaryDirectory();
    final path = tempDirectory.path;
    IMD.Image mImageFile = IMD.decodeImage(file.readAsBytesSync());
    // Take note of the double .. below
    final compressedImageFIle = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(IMD.encodeJpg(mImageFile, quality: 60));
    setState(() {
      this.file = compressedImageFIle;
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask storageUploadTask =
        storageReference.child("post_$postId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  controlUploadAndSave() async {
    print("IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");
    setState(() {
      uploading = true;
    });
    await compressPhoto();
    String downloadUrl = await uploadPhoto(file);
    savePostInfoToFirestore(
        url: downloadUrl,
        location: _location.text,
        description: _description.text);
    _description.clear();
    _location.clear();
    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  savePostInfoToFirestore({String url, String location, String description}) {
    postsReference
        .document(currentSignInUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postID": postId,
      "ownerId": currentSignInUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": currentSignInUser.username,
      "description": description,
      "location": location,
      "url": url
    });
  }

  displayUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: clearPostInfo),
        title: Text("New Post",
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        actions: <Widget>[
          FlatButton(
              onPressed: uploading == true ? null: controlUploadAndSave,
              child: Text(
                "Share",
                style: TextStyle(
                    color: Colors.lightGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0),
              ))
        ],
      ),
      body: ListView(
        children: <Widget>[

          uploading == true? linearProgress():Text(""),
          Container(
            height: 230.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(file), fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12.0)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(currentSignInUser.url),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _description,
                decoration: InputDecoration(
                    hintText: "Say something about your image",
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.person_pin_circle,
              color: Colors.white,
              size: 36.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _location,
                decoration: InputDecoration(
                    hintText: "Write the location",
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 220.0,
            height: 110.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35.0),
              ),
              color: Colors.green,
              icon: Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              label: Text(
                "Get Current Location",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: getUserCurrentLocation,
            ),
          )
        ],
      ),
    );
  }
 bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen() : displayUploadForm();
  }
}
