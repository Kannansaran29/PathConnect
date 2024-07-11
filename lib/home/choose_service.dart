import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pathconnect/drop/drop_ship.dart';
import 'package:pathconnect/hitchhiker/publish_hitch.dart';
import 'package:pathconnect/hitchhiker/hitch_select.dart';
import 'package:pathconnect/ride/ride_request.dart';

class ServiceSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Service'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hi ${FirebaseAuth.instance.currentUser!.displayName == null ? 'User' : FirebaseAuth.instance.currentUser!.displayName},',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10), // Adding some vertical spacing
            Text(
              'Welcome to Path Connect!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10), // Adding more vertical spacing
            Text(
              'Please select a service below:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20), // Adding more vertical spacing
            Center(child: Lottie.asset('assets/images/intro2.json', height: 250)),
            SizedBox(height: 20), // Adding more vertical spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ServiceOptionCard(
                  icon: Icons.shopping_bag,
                  text: 'Dropshipping',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DropShippingPage()),
                    );
                  },
                ),
                SizedBox(height: 20),
                // ServiceOptionCard(
                //   icon: Icons.directions_car,
                //   text: 'Request Ride',
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => RideRequestPage()),
                //     );
                //   },
                // ),
              ServiceOptionCard(
              icon: Icons.directions_car,
              text: 'Ride',
              onPressed: () {
                // Navigate to the HitchhikePage when pressed
                // Replace `HitchhikePage` with your actual page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HitchhikeSelectorPage()),
                );
              },
            ),
              ],
            ),
            SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }
}

class ServiceOptionCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const ServiceOptionCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      width: 170,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
