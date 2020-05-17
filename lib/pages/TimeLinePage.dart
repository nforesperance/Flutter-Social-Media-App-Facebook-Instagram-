import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context,isAppTitle: true),
    );
  }
}
