import 'dart:math' show Random, asin, cos, pi, sin, sqrt;

import 'package:cloud_firestore/cloud_firestore.dart' as Fire;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:lottie/lottie.dart';
import 'package:pathconnect/ride/search_page.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DropShippingPage extends StatefulWidget {
  @override
  _DropShippingPageState createState() => _DropShippingPageState();
}

class _DropShippingPageState extends State<DropShippingPage> {
  ValueNotifier<GeoPoint?> currentLocationNotifier = ValueNotifier(null);
  ValueNotifier<GeoPoint?> destinationLocationNotifier = ValueNotifier(null);
  final _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();

  TextEditingController dateandtime = TextEditingController();

  TextEditingController phone = TextEditingController();
  double rideDistance = 0.0;
  double packageWeight = 0.0;
  double packageHeight = 0.0;
  double packageWidth = 0.0;
  double packageBreadth = 0.0;
  double totalRideAmount = 0.0;
  TextEditingController locationName = TextEditingController();
  TextEditingController destinationName = TextEditingController();
  final Fire.FirebaseFirestore _firestore = Fire.FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drop Shipping'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Lottie.asset('assets/images/drop_ship.json',
                      height: 300)),
              SizedBox(height: 20),
              _buildTextInputField(
                labelText: 'Start Location',
                controller: locationName,
              ),
              // SizedBox(height: 20),
              // _buildTextInputField(
              //   labelText: 'Date and Time',
              //   controller: dateandtime,
              // ),
              SizedBox(height: 20),
              _buildTextInputField(
                labelText: 'Destination',
                controller: destinationName,
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 16),
              _buildPackageDetails(),
              _buildCustomerInfo(),
              SizedBox(height: 16),
              Center(child: _buildConfirmButton()),
              SizedBox(height: 20),
            ],
          ),
        ),
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
                      SizedBox(height: 20),
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
                      SizedBox(height: 20),
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

  Widget _buildCustomerInfo() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recepient Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SizedBox(height: 20),
            _buildTextInputField(
              labelText: 'Receiver Name',
              controller: name,
            ),
            SizedBox(height: 20),
            _buildTextInputField(
              labelText: 'Contact Number',
              controller: phone,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageDetails() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Package Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter package weight';
                }
                return null;
              },
              onSaved: (value) {
                packageWeight = double.parse(value!);
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter package height';
                }
                return null;
              },
              onSaved: (value) {
                packageHeight = double.parse(value!);
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'Width (cm)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter package width';
                }
                return null;
              },
              onSaved: (value) {
                packageWidth = double.parse(value!);
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'Breadth (cm)'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter package breadth';
                }
                return null;
              },
              onSaved: (value) {
                packageBreadth = double.parse(value!);
              },
            ),
          ],
        ),
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
          'Confirm Drop',
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
      // Base rate: ₹5 per km
      double baseAmount = rideDistance * 5;
      // Additional charges based on package weight, height, and width
      double weightCharge = packageWeight * 10; // ₹10 per kg
      double volumeCharge =
          packageHeight * packageWidth * packageBreadth * 1; // ₹1 per cubic cm
      totalRideAmount = baseAmount + weightCharge + volumeCharge;
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
    _calculateRideDetails();
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
      'type': 'drop',
      'status': 'pending',
      'userContactNumber': '',
      'assignedDeliveryUserId': '',
      'recepientName': name.text.trim(),
      'recepientContactNumber': phone.text.trim(),
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'orderId': orderId,
      'currentLocationLatitude': currentLocationNotifier.value!.latitude,
      'currentLocationLongitude': currentLocationNotifier.value!.longitude,
      'destinationLocationLatitude':
          destinationLocationNotifier.value!.latitude,
      'destinationLocationLongitude':
          destinationLocationNotifier.value!.longitude,
      'packageWeight': packageWeight,
      'packageHeight': packageHeight,
                  'dateandtime': dateandtime.text.trim(),
      'locationName': locationName.text.trim(),
      'destinationName': destinationName.text.trim(),
      'packageWidth': packageWidth,
      'packageBreadth': packageBreadth,
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
