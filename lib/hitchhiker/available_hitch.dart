import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pathconnect/two_points.dart';
import 'dart:math' as math;

import 'package:razorpay_flutter/razorpay_flutter.dart';

class AvailableHitchOrdersPage extends StatefulWidget {
  @override
  State<AvailableHitchOrdersPage> createState() =>
      _AvailableHitchOrdersPageState();
}

class _AvailableHitchOrdersPageState extends State<AvailableHitchOrdersPage> {
  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    showAlertDialog(context, "Payment Failed",
        "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
    showSnackBar(context, "Payment Failed");
  }

  String selectedDoc = '';

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    // Update the document with the selectedDoc ID in the pathconnectOrder collection
    FirebaseFirestore.instance
        .collection('pathconnectOrder')
        .doc(selectedDoc)
        .update({
      'status': 'accepted',
      'assignedDeliveryUserId': FirebaseAuth.instance.currentUser!.uid
    }).then((_) {
      print('Document updated successfully');
    }).catchError((error) {
      print('Error updating document: $error');
    });

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

  double calculateDistance(
      double startLat, double startLong, double endLat, double endLong) {
    const double earthRadius = 6371; // Earth radius in kilometers

    // Convert latitude and longitude from degrees to radians
    double startLatRad = startLat * (math.pi / 180);
    double startLongRad = startLong * (math.pi / 180);
    double endLatRad = endLat * (math.pi / 180);
    double endLongRad = endLong * (math.pi / 180);

    // Calculate the differences
    double latDiff = endLatRad - startLatRad;
    double longDiff = endLongRad - startLongRad;

    // Calculate the distance using the Haversine formula
    double a = math.pow(math.sin(latDiff / 2), 2) +
        math.cos(startLatRad) *
            math.cos(endLatRad) *
            math.pow(math.sin(longDiff / 2), 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    return distance; // Distance in kilometers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Rides'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pathconnectOrder')
            .where('type', isEqualTo: 'hitch')
            .where('status', isEqualTo: 'pending') 
            // .where('userId',isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No available rides.'));
          }
          List<QueryDocumentSnapshot> hitchOrders = snapshot.data!.docs;
          // Display the list of available hitch orders
          return ListView.builder(
            itemCount: hitchOrders.length,
            itemBuilder: (context, index) {
              var order = hitchOrders[index];
              // Get order details
              String orderId = order['orderId'];
              String status = order['status'];
              double startLatitude = order['currentLocationLatitude'];
              double startLongitude = order['currentLocationLongitude'];
              double endLatitude = order['destinationLocationLatitude'];
              double endLongitude = order['destinationLocationLongitude'];
              double rideDistance = calculateDistance(
                  startLatitude, startLongitude, endLatitude, endLongitude);

              // Build card for each hitch order
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${orderId.toUpperCase()}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Name: ${order['userName']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Contact Number: ${order['contactNumber']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      status == 'pending'
                          ? Text('Status: Avaialble')
                          : Text('Status: Unavaialble'),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 20),
                          SizedBox(width: 5),
                          Text(
                              'Start Location: (${startLatitude.toStringAsPrecision(6)}, ${startLongitude.toStringAsPrecision(6)})'),
                        ],
                      ),
                      Text('Location: (${order['locationName']})'),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 20),
                          SizedBox(width: 5),
                          Text(
                              'End Location: (${endLatitude.toStringAsPrecision(6)}, ${endLongitude.toStringAsPrecision(6)})'),
                        ],
                      ),
                      Text('Location: (${order['destinationName']})'),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Navigate to view destination map
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlotMap(
                                    startLatitude: startLatitude,
                                    startLongitude: startLongitude,
                                    endLatitude: endLatitude,
                                    endLongitude: endLongitude,
                                    titleMessage: 'Destination Map',
                                  ),
                                ),
                              );
                            },
                            child: Text('View Destination Map'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Calculate ride amount
                              double rideAmount =
                                  rideDistance * 10; // 10 Rs per km
                              print(rideAmount);
                              // Show confirmation dialog with ride amount
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Ride'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Ride Amount: ₹${rideAmount.toStringAsFixed(2)}'),
                                        SizedBox(height: 10),
                                        Text(
                                            'Are you sure you want to take this ride?'),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Razorpay razorpay = Razorpay();
                                          var options = {
                                            'key': 'rzp_test_1DP5mmOlF5G5ag',
                                            'amount': rideAmount.toInt() * 100,
                                            'name': 'PathConnect Corp.',
                                            'description': 'Ride',
                                            'retry': {
                                              'enabled': true,
                                              'max_count': 1
                                            },
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
                                              Razorpay.EVENT_PAYMENT_ERROR,
                                              handlePaymentErrorResponse);
                                          razorpay.on(
                                              Razorpay.EVENT_PAYMENT_SUCCESS,
                                              handlePaymentSuccessResponse);
                                          razorpay.on(
                                              Razorpay.EVENT_EXTERNAL_WALLET,
                                              handleExternalWalletSelected);
                                          razorpay.open(options);

                                          selectedDoc = order.reference.id;

                                          // Perform action to confirm the ride
                                          // For example, update the status of the order
                                          // Update assignedDeliveryUserId to current user's uid

                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text('Confirm'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Take Ride'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
