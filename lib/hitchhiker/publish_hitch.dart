import 'dart:math' show Random, asin, cos, pi, sin, sqrt;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as Fire;
import 'package:pathconnect/ride/search_page.dart';

class PublishHitchRide extends StatefulWidget {
  @override
  _PublishHitchRideState createState() => _PublishHitchRideState();
}

class _PublishHitchRideState extends State<PublishHitchRide> {
  final Fire.FirebaseFirestore _firestore = Fire.FirebaseFirestore.instance;
  ValueNotifier<GeoPoint?> currentLocationNotifier = ValueNotifier(null);
  ValueNotifier<GeoPoint?> destinationLocationNotifier = ValueNotifier(null);
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController dateandtime = TextEditingController();
  TextEditingController locationName = TextEditingController();
  TextEditingController destinationName = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double rideDistance = 0.0;
  double totalRideAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publish Ride'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Lottie.asset('assets/images/hitch.json', height: 300),
              ),

               SizedBox(height: 20),
              _buildTextInputField(
                labelText: 'Date and Time',
                controller: dateandtime,
              ),


              SizedBox(height: 20),
              _buildTextInputField(
                labelText: 'Location Name',
                controller: locationName,
              ),
              SizedBox(height: 20),
              _buildTextInputField(
                labelText: 'Destination Name',
                controller: destinationName,
              ),
              SizedBox(height: 20),
              _buildLocationSelection(
                title: 'Start Location',
                notifier: currentLocationNotifier,
                isDestination: false,
              ),
              _buildLocationSelection(
                title: 'Destination',
                notifier: destinationLocationNotifier,
                isDestination: true,
              ),
              SizedBox(height: 20),
              _buildTextInputField(
                labelText: 'Your Name',
                controller: name,
              ),
              SizedBox(height: 20),
              _buildTextInputField(
                labelText: 'Contact Number',
                controller: phone,
              ),
              SizedBox(height: 32),
              SizedBox(height: 16),
              Center(child: _buildConfirmButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelection({
    required String title,
    required ValueNotifier<GeoPoint?> notifier,
    required bool isDestination,
  }) {
    return Card(
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              Icons.location_pin,
              color: Colors.black,
            ),
            onTap: () async {
              var p = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SearchPage(),
                ),
              );
              if (p != null) {
                if (isDestination) {
                  destinationLocationNotifier.value = p as GeoPoint;
                } else {
                  currentLocationNotifier.value = p as GeoPoint;
                }
                _calculateRideDetails();
              }
            },
          ),
          SizedBox(height: 10),
          ValueListenableBuilder<GeoPoint?>(
            valueListenable: notifier,
            builder: (ctx, p, child) {
              if (p != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.map),
                          Text(
                            "Latitude: ${p.latitude.toStringAsPrecision(7)}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.map),
                          Text(
                            "Longitude: ${p.longitude.toStringAsPrecision(7)}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Column(
                    children: [
                      Text(
                        "No location selected",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputField({
    required String labelText,
    required TextEditingController controller,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
      controller: controller,
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _confirmRide();
        }
      },
      child: Text(
        'Confirm Ride',
        style: TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }

  void _calculateRideDetails() {
    if (currentLocationNotifier.value != null &&
        destinationLocationNotifier.value != null) {
      rideDistance = _calculateDistance(
        currentLocationNotifier.value!,
        destinationLocationNotifier.value!,
      );
      totalRideAmount = rideDistance * 5; // Rate: ₹5 per km
      setState(() {});
    }
  }

  double _calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371.0; // Earth radius in kilometers
    final double lat1 = point1.latitude * (pi / 180.0);
    final double lon1 = point1.longitude * (pi / 180.0);
    final double lat2 = point2.latitude * (pi / 180.0);
    final double lon2 = point2.longitude * (pi / 180.0);
    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  void _confirmRide() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Ride'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Text(
              //   'Total Ride Amount: ₹${totalRideAmount.toStringAsFixed(2)}',
              //   style: TextStyle(fontSize: 16),
              // ),
              // SizedBox(height: 10),
              Text(
                'Ride Distance: ${rideDistance.toStringAsFixed(2)} km',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _saveRideDataToFirestore();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Confirm'),
              style: ElevatedButton.styleFrom(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
              style: ElevatedButton.styleFrom(),
            ),
          ],
        );
      },
    );
  }

  void _saveRideDataToFirestore() {
    String orderId = generateRandomId();

    Map<String, dynamic> rideData = {
      'isCompleted': false,
      'type': 'hitch',
      'status': 'pending',
      'assignedDeliveryUserId': '',
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'userName': name.text.trim(),
      'locationName': locationName.text.trim(),
            'dateandtime': dateandtime.text.trim(),
      'destinationName': destinationName.text.trim(),
      'contactNumber': phone.text.trim(),
      'orderId': orderId,
      'currentLocationLatitude': currentLocationNotifier.value!.latitude,
      'currentLocationLongitude': currentLocationNotifier.value!.longitude,
      'destinationLocationLatitude':
          destinationLocationNotifier.value!.latitude,
      'destinationLocationLongitude':
          destinationLocationNotifier.value!.longitude,
      'packageWeight': 0.00,
      'packageHeight': 0.00,
      'packageWidth': 0.00,
      'packageBreadth': 0.00,
      'rideDistance': rideDistance,
      'totalRideAmount': totalRideAmount,
    };

    _firestore.collection('pathconnectOrder').doc(orderId).set(rideData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your ride has been published.'),
      ),
    );
  }

  String generateRandomId() {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    String id = '';
    for (var i = 0; i < 10; i++) {
      id += chars[rnd.nextInt(chars.length)];
    }
    return id;
  }
}
