import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderList extends StatefulWidget {
  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  void _deleteOrder(String orderId) {
  FirebaseFirestore.instance
      .collection('pathconnectOrder')
      .doc(orderId)
      .delete()
      .then((_) {
    // Order deleted successfully
    print('Order deleted successfully');
  }).catchError((error) {
    // Error occurred while deleting the order
    print('Error deleting order: $error');
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Lottie.asset('assets/images/history.json'),
            flex: 2,
          ),
          Expanded(
            flex: 3,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pathconnectOrder')
                  //         .where('userId',
                  //             isEqualTo: FirebaseAuth.instance.currentUser!.uid)

                  //  .where('assignedDeliveryUserId',
                  //             isEqualTo: FirebaseAuth.instance.currentUser!.uid)

                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No orders found.'),
                  );
                }

                List<QueryDocumentSnapshot> orders = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var order = orders[index];
                    bool isDropShipping = order['type'] == 'drop';
                    bool isHitch = order['type'] == 'hitch'; // New line
                    bool isAccepted =
                        isHitch && order['status'] == 'accepted'; // New line
                    bool isPublishedRide = order['userId'] ==
                        FirebaseAuth.instance.currentUser!.uid; // New line

                    IconData leadingIcon = isDropShipping
                        ? Icons.badge
                        : (isHitch
                            ? Icons.thumb_up
                            : Icons.bike_scooter); // Updated line
                    Color leadingColor = isDropShipping
                        ? Colors.purple
                        : (isHitch
                            ? Colors.orange
                            : Colors.green); // Updated line
                    IconData typeIcon = isDropShipping
                        ? Icons.shopping_bag_outlined
                        : (isHitch
                            ? Icons.thumb_up_outlined
                            : Icons.directions_bike_outlined); // Updated line

                    return order['userId'] ==
                                FirebaseAuth.instance.currentUser!.uid ||
                            order['assignedDeliveryUserId'] ==
                                FirebaseAuth.instance.currentUser!.uid
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          leadingIcon,
                                          color: leadingColor,
                                          size: 30,
                                        ),
                                        SizedBox(width: 16),
                                        Text(
                                          'Order ID: ${order['orderId'].toString().toUpperCase()}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  ExpansionTile(
                                    title: Text('Details'),
                                    children: [
                                      if (isPublishedRide) ...[
                                        // Widget to mark as published ride
                                        SizedBox(height: 16),
                                        Text(
                                          'This is your published ride.', // Example text, you can customize this
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],

                                       if (isPublishedRide) ...[
              // Delete button for published ride orders
              ElevatedButton(
                onPressed: () {
                  _deleteOrder(order.id); // Call method to delete the order
                },
                child: Text('Delete Order'),
              ),
            ],
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  typeIcon,
                                                  color: leadingColor,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  isDropShipping
                                                      ? 'Drop Shipping'
                                                      : (isHitch
                                                          ? 'Hitchhike'
                                                          : 'Ride'), // Updated line
                                                  style: TextStyle(
                                                    color: leadingColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (!isAccepted &&
                                                !isPublishedRide) // Show accept button only if the order is not accepted
                                              ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      String contactNumber =
                                                          ''; // Variable to store the contact number
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Enter Contact Number'),
                                                        content: TextField(
                                                          onChanged: (value) {
                                                            contactNumber =
                                                                value;
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                                  hintText:
                                                                      'Contact Number'),
                                                          keyboardType:
                                                              TextInputType
                                                                  .phone,
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              // Close the dialog and accept the order if a contact number is entered
                                                              if (contactNumber
                                                                  .isNotEmpty) {
                                                                // Update assignedDeliveryUserId and status when the button is clicked
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'pathconnectOrder')
                                                                    .doc(order
                                                                        .id) // Assuming 'id' is the document ID of the order
                                                                    .update({
                                                                  'assignedDeliveryUserId':
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid,
                                                                  'status':
                                                                      'accepted',
                                                                  'userContactNumber':
                                                                      contactNumber, // Update contact number
                                                                });
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Close the dialog
                                                              }
                                                            },
                                                            child:
                                                                Text('Accept'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Close the dialog without accepting the order
                                                            },
                                                            child:
                                                                Text('Cancel'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text('Accept Order'),
                                              ),
                                            if (isAccepted &&
                                                !isPublishedRide) // Show a message if the order is already accepted
                                              Text(
                                                'You have accepted this order.',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.info_outline,
                                                    color: Colors.blueGrey),
                                                SizedBox(width: 8),
                                                Text(
                                                    'Status: ${order['status']}'),
                                                    
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                              Row(
                                              children: [
                                                Icon(Icons.lock_clock,
                                                    color: Colors.blueGrey),
                                                SizedBox(width: 8),
                                                Text(
                                                    'Date & Time: ${order['dateandtime']}'),
                                                    
                                              ],
                                            ),   SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.start,
                                                    color: Colors.blueGrey),
                                                SizedBox(width: 8),
                                                Text(
                                                    'Start Location: ${order['locationName']}'),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.edit_note,
                                                    color: Colors.blueGrey),
                                                SizedBox(width: 8),
                                                Text(
                                                    'Destination: ${order['destinationName']}'),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            if (isAccepted) ...[
                                              Row(
                                                children: [
                                                  Icon(Icons.person,
                                                      color: Colors.blueGrey),
                                                  SizedBox(width: 8),
                                                  Text(
                                                      'Name: ${order['userName']}'),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.phone,
                                                      color: Colors.blueGrey),
                                                  SizedBox(width: 8),
                                                  Text(
                                                      'Contact: ${order['contactNumber']}'),
                                                ],
                                              ),
                                            ],
                                            if (!isHitch) ...[
                                              Row(
                                                children: [
                                                  Icon(Icons.social_distance,
                                                      color: Colors.blueGrey),
                                                  SizedBox(width: 8),
                                                  Text(
                                                      'Ride Distance: ${order['rideDistance'].toStringAsPrecision(4)} km'),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.money,
                                                      color: Colors.blueGrey),
                                                  SizedBox(width: 8),
                                                  Text(
                                                      'Total Ride Amount: ₹${order['totalRideAmount'].toStringAsPrecision(4)}'),
                                                ],
                                              ),
                                            ],
                                            if (!isHitch)
                                              if (order['status'] !=
                                                  'completed') ...[
                                                SizedBox(height: 16),
                                                Stepper(
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  controlsBuilder:
                                                      (BuildContext context,
                                                          ControlsDetails
                                                              controlsDetails) {
                                                    return SizedBox.shrink();
                                                  },
                                                  steps: <Step>[
                                                    Step(
                                                      title: Text('Pending'),
                                                      isActive:
                                                          order['status'] ==
                                                              'pending',
                                                      state: order['status'] ==
                                                              'pending'
                                                          ? StepState.editing
                                                          : StepState.complete,
                                                      content: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(height: 8),
                                                          Row(
                                                            children: [
                                                              Icon(Icons.search,
                                                                  color: order[
                                                                              'status'] ==
                                                                          'pending'
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
                                                                          .grey),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                  'Searching for a driver'),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                              'This step indicates that the order is currently searching for a driver to pick it up.'),
                                                        ],
                                                      ),
                                                    ),
                                                    Step(
                                                      title: Text('Picked Up'),
                                                      isActive:
                                                          order['status'] ==
                                                              'picked up',
                                                      state: order['status'] ==
                                                              'picked up'
                                                          ? StepState.editing
                                                          : StepState.complete,
                                                      content: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(height: 8),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .delivery_dining,
                                                                  color: order[
                                                                              'status'] ==
                                                                          'picked up'
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
                                                                          .grey),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(isDropShipping
                                                                  ? 'Package picked up'
                                                                  : (isHitch
                                                                      ? 'Hitchhike picked up'
                                                                      : 'Ride picked up')), // Updated line
                                                            ],
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                              'This step indicates that the ${isDropShipping ? 'package' : (isHitch ? 'hitchhike' : 'ride')} has been picked up.'), // Updated line
                                                        ],
                                                      ),
                                                    ),
                                                    Step(
                                                      title: Text('Completed'),
                                                      isActive:
                                                          order['status'] ==
                                                              'completed',
                                                      state: order['status'] ==
                                                              'completed'
                                                          ? StepState.editing
                                                          : StepState.complete,
                                                      content: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(height: 8),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: order[
                                                                              'status'] ==
                                                                          'completed'
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
                                                                          .grey),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                  'Order delivered'),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                              'This step indicates that the order has been successfully completed.'),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
