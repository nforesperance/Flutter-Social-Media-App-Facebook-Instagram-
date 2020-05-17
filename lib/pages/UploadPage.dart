import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File file;

  captureImageWithCamera() async {
    Navigator.pop(context);
    try {
      File imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: 600,
        maxWidth: 970,
      );
      if (imageFile != null) {
        setState(() {
          this.file = imageFile;
        });
      }
    } catch (e) {}
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    try {
      File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (imageFile != null) {
        setState(() {
          this.file = imageFile;
        });
      }
    } catch (e) {}
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
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: Text(
                "Choose Image From Gallery",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: pickImageFromGallery,
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

  @override
  Widget build(BuildContext context) {
    return displayUploadScreen();
  }
}
