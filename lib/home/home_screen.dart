import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pathconnect/home/about.dart';
import 'package:pathconnect/admin/admin.dart';
import 'package:pathconnect/home/choose_service.dart';
import 'package:pathconnect/delivery/delivery.dart';
import 'package:pathconnect/home/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:pathconnect/order/order_history.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BorderRadius _borderRadius = const BorderRadius.only(
    topLeft: Radius.circular(25),
    topRight: Radius.circular(25),
  );

  ShapeBorder? bottomBarShape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(25)),
  );
  SnakeBarBehaviour snakeBarStyle = SnakeBarBehaviour.floating;
  EdgeInsets padding = const EdgeInsets.all(12);
  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  SnakeShape snakeShape = SnakeShape.circle;

  bool showSelectedLabels = false;
  bool showUnselectedLabels = false;

  Color unselectedColor = Colors.blueGrey;

  Gradient selectedGradient =
      const LinearGradient(colors: [Colors.red, Colors.amber]);
  Gradient unselectedGradient =
      const LinearGradient(colors: [Colors.red, Colors.blueGrey]);

  Color? containerColor;

  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    ServiceSelectionPage(),
    OrderList(),
    const ProfilePage(),
    AboutAppPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int index = 0;

  Future<int?> getUserRole() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('pathconnectUsers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        if (userDoc['userRole'] == 'user') {
          index = 0;
        } else if (userDoc['userRole'] == 'delivery') {
          index = 1;
        } else if (userDoc['userRole'] == 'admin') {
          index = 2;
        }
      });

      return index;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
        // appBar: AppBar(
        //   backgroundColor: Colors.white10,
        //   title: Text('pathconnect'),
        // ),
        body: index == 0
            ? _widgetOptions.elementAt(_selectedIndex)
            : index == 1
                ? DeliveryPage()
                : AdminPage(),
        bottomNavigationBar: index == 0
            ? SnakeNavigationBar.color(
                behaviour: snakeBarStyle,
                snakeShape: snakeShape,
                shape: bottomBarShape,
                padding: padding,

                ///configuration for SnakeNavigationBar.color
               
  
                unselectedItemColor: unselectedColor,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.design_services,
                    ),
                    label: 'Home',
                  ),
               BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'Order',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.info),
                    label: 'ABout',
                  ),
                ],
              )
            : null);
  }
}
