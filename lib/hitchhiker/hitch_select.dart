import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pathconnect/delivery/delivery.dart';
import 'package:pathconnect/hitchhiker/available_hitch.dart';
import 'package:pathconnect/hitchhiker/publish_hitch.dart';

class HitchhikeSelectorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[  SizedBox(height: 50),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Welcome to Ride!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'As a user, you have two options:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset('assets/images/due.json', height: 200),
                SizedBox(height: 20),
                ServiceOptionButton(
                  icon: Icons.directions_car,
                  text: 'Request a Ride',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AvailableHitchOrdersPage()),
                    );
                  },
                ),
                SizedBox(height: 20),
                ServiceOptionButton(
                  icon: Icons.add,
                  text: 'Publish a Ride',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PublishHitchRide()),
                    );
                  },
                ),

                SizedBox(height: 20),
                ServiceOptionButton(
                  icon: Icons.delivery_dining,
                  text: 'Deliver Order',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeliveryPage()),
                    );
                  },
                ),














        
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceOptionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const ServiceOptionButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
