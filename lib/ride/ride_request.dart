import 'dart:math' show Random, asin, cos, pi, sin, sqrt;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:lottie/lottie.dart';
import 'package:pathconnect/ride/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as Fire;

class RideRequestPage extends StatefulWidget {
  @override
  _RideRequestPageState createState() => _RideRequestPageState();
}

class _RideRequestPageState extends State<RideRequestPage> {
  final Fire.FirebaseFirestore _firestore = Fire.FirebaseFirestore.instance;
  ValueNotifier<GeoPoint?> currentLocationNotifier = ValueNotifier(null);
  ValueNotifier<GeoPoint?> destinationLocationNotifier = ValueNotifier(null);
  final _formKey = GlobalKey<FormState>();

  double rideDistance = 0.0;
  double totalRideAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request a Ride'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Lottie.asset('assets/images/carr.json', height: 300)),
              SizedBox(
                height: 20,
              ),
              _buildLocationSelection(
                title: 'Pickup Location',
                notifier: currentLocationNotifier,
                isDestination: false,
              ),
              _buildLocationSelection(
                title: 'Destination',
                notifier: destinationLocationNotifier,
                isDestination: true,
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

  Widget _buildConfirmButton() {
    return Center(
      child: ElevatedButton(
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

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    showAlertDialog(context, "Payment Failed",
        "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
    showSnackBar(context, "Payment Failed");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    _saveRideDataToFirestore();
    print(response.data.toString());
    showAlertDialog(
        context, "Payment Successful", "Payment ID: ${response.paymentId}");
    showSnackBar(context, "Payment Successful");
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
    showSnackBar(context, "External Wallet Selected");
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
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
              Text(
                'Total Ride Amount: ₹${totalRideAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Ride Distance: ${rideDistance.toStringAsFixed(2)} km',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Razorpay razorpay = Razorpay();
                var options = {
                  'key': 'rzp_test_1DP5mmOlF5G5ag',
                  'amount': totalRideAmount.toInt() * 100,
                  'name': 'PathConnect Corp.',
                  'description': 'Ride',
                  'retry': {'enabled': true, 'max_count': 1},
                  'send_sms_hash': true,
                  'prefill': {
                    'contact': '8888888888',
                    'email': 'test@razorpay.com'
                  },
                  'external': {
                    'wallets': ['paytm']
                  }
                };
                razorpay.on(
                    Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
                razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                    handlePaymentSuccessResponse);
                razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                    handleExternalWalletSelected);
                razorpay.open(options);
                //
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
    // Generate a random ID
    String orderId = generateRandomId();

// Data to be saved
    Map<String, dynamic> rideData = {
      'isCompleted': false,
      'type': 'ride',
      'status': 'pending',
      'assignedDeliveryUserId': '',
      'userContactNumber' : '',
      'userId': FirebaseAuth.instance.currentUser!.uid,
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

    // Save data to Firestore
    _firestore.collection('pathconnectOrder').doc(orderId).set(rideData);
  }

  String generateRandomId() {
    // Generate a random alphanumeric string of length 10
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
