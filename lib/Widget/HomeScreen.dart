import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:post_house_rent_app/Widget/AccountManager.dart';
import 'package:post_house_rent_app/Widget/Search.dart';
import 'package:post_house_rent_app/Widget/ShowPost.dart';
import 'package:post_house_rent_app/Widget/TestLayToaDo.dart';
import 'package:post_house_rent_app/Widget/map_page.dart';

import '../CheckInternet.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  static final List<Widget> _widgetOptions = <Widget>[
    ShowPostWidget(),
    SearchWidget(),
    AccountWidget(),
    MapPageWidget(),
    TestPageWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConnectivityWidgetWrapper(
        child: IndexedStack(
          index: _currentIndex,
          children: _widgetOptions,
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        color: Colors.teal,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: Colors.tealAccent),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.tealAccent),
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite, color: Colors.tealAccent),
              onPressed: () {
                // Action when the favorite button is pressed
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.tealAccent),
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.map, color: Colors.tealAccent),
              onPressed: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.check_box, color: Colors.tealAccent),
              onPressed: () {
                setState(() {
                  _currentIndex = 4;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ShowPostWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShowPost(); // Your search screen content here
  }
}

class SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Search(); // Your search screen content here
  }
}

class AccountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AccountManager(); // Your account screen content here
  }
}
class MapPageWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MapPage();
  }

}
class TestPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetLocationPage();
  }
}
